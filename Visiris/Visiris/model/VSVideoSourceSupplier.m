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

@property (assign) double                   videoDuration;
@property (strong) AVAssetReader            *movieReader;
@property (strong) NSURL                    *url;
@property (strong) NSDate                   *startTime;
@property (assign) BOOL                     isReadingVideo;
@property (assign) char*                    imageData;
@property (strong) AVURLAsset               *asset;
@property (strong) AVAssetImageGenerator    *imageGenerator;
@property (assign) float                    frameRate;
@property (assign) int                      currentFrame;

- (void) readMovie:(NSURL *)url atTime:(double) time;
- (void) readNextMovieFrame;
- (void) updateInfo: (id)message;

@end


@implementation VSVideoSourceSupplier
@synthesize videoDuration   = _videoDuration;
@synthesize movieReader     = _movieReader;
@synthesize url             = _url;
@synthesize startTime       = _startTime;
@synthesize vsImage         = _vsImage;
@synthesize isReadingVideo  = _isReadingVideo;
@synthesize imageData       = _imageData;
@synthesize asset           = _asset;
@synthesize imageGenerator  = _imageGenerator;
@synthesize frameRate       = _frameRate;
@synthesize currentFrame    = _currentFrame;

- (id)initWithTimelineObject:(VSTimelineObject *)aTimelineObject{
    if (self = [super initWithTimelineObject:aTimelineObject]) {
        self.url = [[NSURL alloc] initFileURLWithPath:self.timelineObject.sourceObject.filePath]; 
        self.vsImage = [[VSImage alloc] init];
        self.asset = [AVURLAsset URLAssetWithURL:self.url options:nil];
        self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
        self.imageGenerator.appliesPreferredTrackTransform = YES;
        self.vsImage.size = self.asset.naturalSize;
        self.imageData = malloc(self.vsImage.size.width * self.vsImage.size.height * 4);
        
        [self readMovie:self.url atTime:0];
        self.isReadingVideo = YES;
    }
    return self;
}

-(VSImage *) getFrameForTimestamp:(double)aTimestamp withPlayMode:(VSPlaybackMode)playMode{

    //TODO this is sparta - no its slow!
    
    double videoTimestamp = [self convertToVideoTimestamp:aTimestamp] / 1000.0;
    
    //NSLog(@"TimeStamp: %f", videoTimestamp);
    
    if (playMode == VSPlaybackModePlaying) {
        
        if(self.currentFrame > 60 && videoTimestamp < 1.0 ){
            [self.movieReader cancelReading];
            [self readMovie:self.url atTime:videoTimestamp];
            [self readNextMovieFrame];
        } 
        
        if (self.isReadingVideo == NO) {
            self.isReadingVideo = YES;
            [self readMovie:self.url atTime:videoTimestamp];
        } 
        
        if (self.currentFrame < [self framesFromSeconds:videoTimestamp]) {
            [self readNextMovieFrame];
            self.currentFrame++;
            self.vsImage.needsUpdate = YES;
        }
    }
    else {
        [self getPreviewImageAtTime:videoTimestamp];
        self.isReadingVideo = NO;
        [self.movieReader cancelReading];
        self.vsImage.needsUpdate = YES;
    }
    return self.vsImage;
}

- (void)getPreviewImageAtTime:(double) timeStamp{         
    CMTime timePoint = CMTimeMakeWithSeconds(timeStamp, self.asset.duration.timescale);  
    
    CMTime actualTime;
    NSError *error = nil;
    
    CGImageRef image = [self.imageGenerator copyCGImageAtTime:timePoint actualTime:&actualTime error:&error];
    
    if (image != NULL) {
        //NSString *actualTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, actualTime);
        //NSString *requestedTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, timePoint);
        //NSLog(@"got image: Asked for %@, got %@", requestedTimeString, actualTimeString);
                
        CGRect rect = CGRectMake(0.0f, 0.0f, self.vsImage.size.width, self.vsImage.size.height);        
        CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef ctx = CGBitmapContextCreate(self.imageData, self.vsImage.size.width, self.vsImage.size.height, 8, self.vsImage.size.width * 4, colourSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
        CFRelease(colourSpace);
        //CGContextTranslateCTM(ctx, 0, height);
        //CGContextScaleCTM(ctx, 1.0f, -1.0f);
        CGContextSetBlendMode(ctx, kCGBlendModeCopy);
        CGContextDrawImage(ctx, rect, image);
        CGContextRelease(ctx);
        CFRelease(image);
        self.vsImage.data = self.imageData;
    }
}

- (void) readMovie:(NSURL *)url atTime:(double) time{    
    self.startTime = [NSDate date];
        
    [self.asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            AVAssetTrack* videoTrack = nil;
                            NSArray* tracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
                            if ([tracks count] == 1)
                            {
                                videoTrack = [tracks objectAtIndex:0];
                                
                                self.videoDuration = CMTimeGetSeconds([videoTrack timeRange].duration);
                                
                                NSError * error = nil;
                                
                                self.movieReader = [[AVAssetReader alloc] initWithAsset:self.asset error:&error];
                                if (error)
                                    NSLog(@"%@", error.localizedDescription);       
                                
                                NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
                                NSNumber* value = [NSNumber numberWithUnsignedInt: kCVPixelFormatType_32BGRA];
                                NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
                                
                                AVAssetReaderTrackOutput* output = [AVAssetReaderTrackOutput 
                                                                    assetReaderTrackOutputWithTrack:videoTrack 
                                                                    outputSettings:videoSettings];
                                //    output.alwaysCopiesSampleData = NO;
                                
                                [self.movieReader addOutput:output];
                                
                                
                                CMTime cmtime = CMTimeMakeWithSeconds(time,self.asset.duration.timescale);
                                
                                CMTimeRange timeRange = CMTimeRangeMake(cmtime, kCMTimePositiveInfinity);
                                [self.movieReader setTimeRange:timeRange];
                                
//                                NSLog(@"timeRange: %@", (__bridge NSString *)CMTimeCopyDescription(NULL, cmtime));
//                                NSLog(@"insgesammt frames: %lld", self.movieReader.asset.duration.value);
//                                NSLog(@"framerate: %f", videoTrack.nominalFrameRate);
                                
                                self.frameRate = videoTrack.nominalFrameRate;
                                self.currentFrame = [self framesFromSeconds:time];

                                if ([self.movieReader startReading]){
                                    //NSLog(@"Video Reading ready");
                                }
                                else{
                                    NSLog(@"reading can't be started");
                                }
                            }
                        });
     }];
}

- (void) updateInfo:(id)message{
    NSLog(@"%@",message);
}



- (void) readNextMovieFrame{        
    if (self.movieReader.status == AVAssetReaderStatusReading){        
        AVAssetReaderTrackOutput * output = [self.movieReader.outputs objectAtIndex:0];
        //[output ]
        CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer]; // this is the most expensive call
        if (sampleBuffer)
        { 
            //CVImageBufferRef
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
                        
            // Lock the image buffer
            CVPixelBufferLockBaseAddress(imageBuffer,0);

            if (self.vsImage == nil) {
                self.vsImage = [[VSImage alloc] init];
            }
            
            self.vsImage.data = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
            self.vsImage.size = NSMakeSize(CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer));
            
            // Unlock the image buffer
            CVPixelBufferUnlockBaseAddress(imageBuffer,0);
            
            CFRelease(sampleBuffer);
        }
        else{
            NSLog(@"could not copy next sample buffer. status is %ld", self.movieReader.status);
            NSTimeInterval scanDuration = -[self.startTime timeIntervalSinceNow];
            float scanMultiplier = self.videoDuration / scanDuration;
            NSString* info = [NSString stringWithFormat:@"Done\n\nvideo duration: %f seconds\nscan duration: %f seconds\nmultiplier: %f", self.videoDuration, scanDuration, scanMultiplier];
           [self performSelectorOnMainThread:@selector(updateInfo:) withObject:info waitUntilDone:YES];
        }
    }
    else{
        //NSLog(@"Video status is now %ld", self.movieReader.status);
    }
}
- (double)framesFromSeconds:(double)seconds{
    int intSeconds;
    double frames;
    intSeconds = (int)seconds;
    frames = intSeconds * self.frameRate;
    double remain = seconds - intSeconds;
    frames += self.frameRate*remain;
    return frames;
}

-(double) convertToVideoTimestamp:(double)localTimestamp{
    localTimestamp = localTimestamp <= self.timelineObject.sourceDuration ? localTimestamp :  fmod(localTimestamp, self.timelineObject.sourceDuration);

    return localTimestamp;
}

@end
