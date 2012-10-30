//
//  VSVideoSourceSupplier.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSVideoSourceSupplier.h"

#import "AVFoundation/AVFoundation.h"
#import "VisirisCore/VSImage.h"
#import "VSTimelineObject.h"
#import "VSTimelineObjectSource.h"

#import "VSCoreServices.h"

@interface VSSourceSupplier()

/** Reads out the movie frame by frame */
@property (strong) AVAssetReader            *movieReader;

/** Path of the actual file on the System */
@property (strong) NSURL                    *url;

/** Flaf if currentlich Video is playing or just skimming through */
@property (assign) BOOL                     isReadingVideo;

/** Data of the Image */
@property (assign) char*                    imageData;

/** Asset of the File - contains all the data of it */
@property (strong) AVURLAsset               *asset;

/** When user is just skimming through the videofile the imagegenerator creates the imagedata */
@property (strong) AVAssetImageGenerator    *imageGenerator;

/** Frames per second of the Video */
@property (assign) float                    frameRate;

/** The Frame the movieReader is currently at */
@property (assign) int                      currentFrame;

@end


@implementation VSVideoSourceSupplier
@synthesize movieReader     = _movieReader;
@synthesize url             = _url;
@synthesize vsImage         = _vsImage;
@synthesize isReadingVideo  = _isReadingVideo;
@synthesize imageData       = _imageData;
@synthesize asset           = _asset;
@synthesize imageGenerator  = _imageGenerator;
@synthesize frameRate       = _frameRate;
@synthesize currentFrame    = _currentFrame;
@synthesize hasAudio        = _hasAudio;
@synthesize videoTimestamp  = _videoTimestamp;


#pragma mark - Init

/**
 * Initialization of the Timelineobject
 * @param aTimelineObject The Referencing Timelineobject
 */
- (id)initWithTimelineObject:(VSTimelineObject *)aTimelineObject{
    if (self = [super initWithTimelineObject:aTimelineObject]) {
        self.url = [[NSURL alloc] initFileURLWithPath:self.timelineObject.sourceObject.filePath]; 
        self.vsImage = [[VSImage alloc] init];
        self.asset = [AVURLAsset URLAssetWithURL:self.url options:nil];
        self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
        self.imageGenerator.appliesPreferredTrackTransform = YES;
        self.vsImage.size = self.asset.naturalSize;
        self.imageData = malloc(self.vsImage.size.width * self.vsImage.size.height * 4);
        self.videoTimestamp = 0.0;
        
        [self readMovieAtTime:0];
        self.isReadingVideo = YES;
        
        if ([self.asset tracksWithMediaType:AVMediaTypeAudio].count > 0)
        {
            self.hasAudio = YES;
//            NSImage *blubb = [VSWaveForm renderPNGAudioPictogramForAssett:self.asset];
        }
        else
            self.hasAudio = NO;
    }
    return self;
}


#pragma mark - Methods

/**
 * This method gets called every update. It supplies the VSImage
 * @param aTimestamp The localTimestamp of the timelineobject
 * @param playMode Playmode is either skimming, klicking or playing.
 * @return The returnvalue is the updated VSImgae Object
 */
-(VSImage *) getFrameForTimestamp:(double)aTimestamp withPlayMode:(VSPlaybackMode)playMode{
//    DDLogInfo(@"START********************************");
    //TODO this is sparta - no its slow!
    self.videoTimestamp= [self convertToVideoTimestamp:aTimestamp] / 1000.0;

    if (playMode == VSPlaybackModePlaying) {
        double frames = [self framesFromSeconds:self.videoTimestamp];
        
        if (self.isReadingVideo == NO) {
            self.isReadingVideo = YES;
            [self readMovieAtTime:self.videoTimestamp];
        }
        else if (self.movieReader.status != AVAssetReaderStatusReading)
        {
            //If the movieReader is not reading then return the current status of the vsImage (means an empty texture)
            return self.vsImage;
        }
        else if(fabs(frames - self.currentFrame) > self.frameRate){
            [self.movieReader cancelReading];
            [self readMovieAtTime:self.videoTimestamp];
        }
        else if(self.currentFrame < frames) {
            [self readNextMovieFrame];
            self.currentFrame++;
            self.vsImage.needsUpdate = YES;
        }
    }
    else {
        [self getPreviewImageAtTime:self.videoTimestamp];
        self.isReadingVideo = NO;
        [self.movieReader cancelReading];
        self.vsImage.needsUpdate = YES;
    }
//    DDLogInfo(@"END********************************");

    return self.vsImage;
}


#pragma mark - Private Methods

/**
 * This method provides a Image at a given Time. It is not fast but the only way of getting an Image at a given Timestamp
 * @param timeStamp The Timestamp we want to know
 */
- (void)getPreviewImageAtTime:(double)timeStamp{         
    CMTime timePoint = CMTimeMakeWithSeconds(timeStamp, self.asset.duration.timescale);  
    
    CMTime actualTime;
    NSError *error = nil;
    
    CGImageRef image = [self.imageGenerator copyCGImageAtTime:timePoint actualTime:&actualTime error:&error];
    
    if (image != NULL) {
        CGRect rect = CGRectMake(0.0f, 0.0f, self.vsImage.size.width, self.vsImage.size.height);        
        CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef ctx = CGBitmapContextCreate(self.imageData, self.vsImage.size.width, self.vsImage.size.height, 8, self.vsImage.size.width * 4, colourSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
        CFRelease(colourSpace);
        CGContextSetBlendMode(ctx, kCGBlendModeCopy);
        CGContextDrawImage(ctx, rect, image);
        CGContextRelease(ctx);
        CFRelease(image);
        self.vsImage.data = self.imageData;
    }
}

/**
 * This method gets called when the Videostartsplaying and initializes Asset.
 * @param time The Starttime
 */
- (void) readMovieAtTime:(double)time{    
    [self.asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(),
                        ^{                            
                            AVAssetTrack* videoTrack = nil;
                            NSArray* tracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
                            if ([tracks count] == 1)
                            {
                                videoTrack = [tracks objectAtIndex:0];
                                                                
                                NSError * error = nil;
                                
                                self.movieReader = [[AVAssetReader alloc] initWithAsset:self.asset error:&error];
                                if (error)
                                    NSLog(@"%@", error.localizedDescription);       
                                
                                NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
                                NSNumber* value = [NSNumber numberWithUnsignedInt: kCVPixelFormatType_32BGRA];
                                NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
                                
                                AVAssetReaderTrackOutput* output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack
                                                                                                              outputSettings:videoSettings];                                
                                [self.movieReader addOutput:output];
                                
                                                            
                                CMTime cmtime = CMTimeMakeWithSeconds(time,self.asset.duration.timescale);
                                
                                CMTimeRange timeRange = CMTimeRangeMake(cmtime, kCMTimePositiveInfinity);
                                [self.movieReader setTimeRange:timeRange];
                                
                                self.frameRate = videoTrack.nominalFrameRate;
                                self.currentFrame = [self framesFromSeconds:time];

                                if ([self.movieReader startReading] == NO){
                                    NSLog(@"reading can't be started");
                                }
                            }
                        });
     }];
}

/**
 * Reads out a frame and saves it into the VSImagedata
 */
- (void)readNextMovieFrame{
    if (self.movieReader.status == AVAssetReaderStatusReading){
        AVAssetReaderTrackOutput * output = [self.movieReader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer]; // this is the most expensive call
        if (sampleBuffer)
        { 
            //CVImageBufferRef
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
                        
            // Lock the image buffer
            CVPixelBufferLockBaseAddress(imageBuffer,0);

            
            self.vsImage.data = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
//            self.vsImage.size = NSMakeSize(CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer));
            
            // Unlock the image buffer
            CVPixelBufferUnlockBaseAddress(imageBuffer,0);
            
            CFRelease(sampleBuffer);
        }
        else{
            NSLog(@"could not copy next sample buffer. status is %ld", self.movieReader.status);
        }
    }
    else{
        NSLog(@"Video status is now %ld", self.movieReader.status);
    }
}

/**
 * Creates Frames from Seconds
 * @param seconds The Seconds we want calculated to frames
 * @return the Actual frames - normally frames can only be Integer, but this returns a double (maybe this should be improved, not by casting it in a int, rounding it to the nearest int)
 */
- (double)framesFromSeconds:(double)seconds{
    int intSeconds;
    double frames;
    intSeconds = (int)seconds;
    frames = intSeconds * self.frameRate;
    double remain = seconds - intSeconds;
    frames += self.frameRate*remain;
    return frames;
}

/**
 * Converts the localTimestamp to a videoTimeStamp (handles Looping)
 * @param localTimestamp localtimestamp of the Timelineobject
 * @return the VideoTimestamp
 */
- (double)convertToVideoTimestamp:(double)localTimestamp{
    localTimestamp = localTimestamp <= self.timelineObject.sourceDuration ? localTimestamp :  fmod(localTimestamp, self.timelineObject.sourceDuration);
    return localTimestamp;
}

- (void)dealloc{
//    NSLog(@"free");
    free(self.imageData);
}

@end
