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
#import "VSProjectItem.h"

@interface VSSourceSupplier()

@property (assign) double           videoDuration;
@property (strong) AVAssetReader    *movieReader;
@property (strong) NSURL            *url;
@property (strong) NSDate           *startTime;
@property (assign) BOOL             isReadingVideo;
//@property (assign) float            framesPerSecond;
@property (assign) char*            imageData;

- (void) readMovie:(NSURL *)url atTime:(double) time;
- (void) readNextMovieFrame;
- (void) updateInfo: (id*)message;

@end


@implementation VSVideoSourceSupplier
@synthesize videoDuration   = _videoDuration;
@synthesize movieReader     = _movieReader;
@synthesize url             = _url;
@synthesize startTime       = _startTime;
@synthesize vsImage         = _vsImage;
@synthesize isReadingVideo  = _isReadingVideo;
@synthesize imageData       = _imageData;
//@synthesize framesPerSecond = _framesPerSecond;

- (id)init{
    if (self = [super init]) {
        //self.url = [[NSURL alloc] initFileURLWithPath:self.timelineObject.sourceObject.projectItem.filePath]; 

    }
    return self;
}

-(VSImage *) getFrameForTimestamp:(double)aTimestamp isPlaying:(BOOL)playing{
    //TODO this is sparta - no its slow!
    aTimestamp /= 1000.0;
    
     if (self.url == nil) {
         self.url = [[NSURL alloc] initFileURLWithPath:self.timelineObject.sourceObject.projectItem.filePath]; 
     }

    switch (playing) {
        case 0:
            [self getPreviewImageAtTime:aTimestamp];
            self.isReadingVideo = NO;
            [self.movieReader cancelReading];
            break;
        case 1:
            if (self.isReadingVideo == NO) {
                self.isReadingVideo = YES;
                [self readMovie:self.url atTime:aTimestamp];
            }
            [self readNextMovieFrame];
            break;
        default:
            NSLog(@"There went something terribly wrong!");
            break;
    }   
        
    NSLog(@"timescale: %d", self.movieReader.asset.duration.timescale);
    NSLog(@"value: %lld", self.movieReader.asset.duration.value);
        
    return self.vsImage;
}

- (void)getPreviewImageAtTime:(double) timeStamp{         
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:self.url options:nil];;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    CMTime timePoint = CMTimeMakeWithSeconds(timeStamp, 600);  
    
    CMTime actualTime;
    NSError *error = nil;
    
    CGImageRef image = [imageGenerator copyCGImageAtTime:timePoint actualTime:&actualTime error:&error];
    
    if (image != NULL) {
        //NSString *actualTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, actualTime);
        //NSString *requestedTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, timePoint);
        // NSLog(@"got image: Asked for %@, got %@", requestedTimeString, actualTimeString);
        
        if (self.vsImage == nil) {
            self.vsImage = [[VSImage alloc] init];
            self.vsImage.size = NSMakeSize(CGImageGetWidth (image), CGImageGetHeight(image));
            self.imageData = malloc(self.vsImage.size.width * self.vsImage.size.height * 4);
        }
        
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
    
    AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            AVAssetTrack* videoTrack = nil;
                            NSArray* tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
                            if ([tracks count] == 1)
                            {
                                videoTrack = [tracks objectAtIndex:0];
                                
                                self.videoDuration = CMTimeGetSeconds([videoTrack timeRange].duration);
                                
                                NSError * error = nil;
                                
                                self.movieReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
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
                                
                                CMTimeRange timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(time,600), kCMTimePositiveInfinity);
                                [self.movieReader setTimeRange:timeRange];
                                                                
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

- (void) updateInfo: (id*)message{
    NSString* info = [NSString stringWithFormat:@"%@", message];
    NSLog(@"%@",info);
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

@end
