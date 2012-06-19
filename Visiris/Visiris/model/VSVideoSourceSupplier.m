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
//@property (strong) AVPlayer         *player;

- (void) readMovie:(NSURL *)url atTime:(CMTime) time;
- (void) readNextMovieFrame;
- (void) updateInfo: (id*)message;

@end


@implementation VSVideoSourceSupplier
@synthesize videoDuration   = _videoDuration;
@synthesize movieReader     = _movieReader;
@synthesize url             = _url;
@synthesize startTime       = _startTime;
//@synthesize player          = _player;

-(VSImage *) getFrameForTimestamp:(double)aTimestamp{
    
    aTimestamp /= 1000.0;
    
    //TODO this is shit
    //self.url = nil;
    //[self.movieReader cancelReading];
    //self.movieReader = nil;


    if (self.url == nil) {
        self.url = [[NSURL alloc] initFileURLWithPath:self.timelineObject.sourceObject.projectItem.filePath]; 
        [self readMovie:self.url atTime:CMTimeMakeWithSeconds(aTimestamp, 600)];
    }
    
    /*
    if (self.movieReader.status == 1) {
        [self.movieReader cancelReading];
        NSLog(@"status = 1");
        [self readMovie:self.url atTime:CMTimeMakeWithSeconds(aTimestamp, 600)];
    }
    else {
        NSLog(@"status != 1");
    }

       */


    //[self readNextMovieFrame];
    
    
    
    /*NSLog(@"timestamp: %@", [NSNumber numberWithDouble:aTimestamp]);
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:self.timelineObject.sourceObject.projectItem.filePath]; 

    AVAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    CMTime timePoint = CMTimeMakeWithSeconds(aTimestamp, 600);  

    CMTime actualTime;
    NSError *error = nil;
    
    CGImageRef image = [imageGenerator copyCGImageAtTime:timePoint actualTime:&actualTime error:&error];

    if (image != NULL) {
        //NSString *actualTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, actualTime);
        //NSString *requestedTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, timePoint);
       // NSLog(@"got image: Asked for %@, got %@", requestedTimeString, actualTimeString);
        
        if (self.vsImage == nil) {
            self.vsImage = [[VSImage alloc] init];
        }
        
        // Do something interesting with the image.
        size_t width  = CGImageGetWidth (image);
        size_t height = CGImageGetHeight(image);
        CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
        
        void *imageData = malloc(width * height * 4);
        CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef ctx = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
        CFRelease(colourSpace);
        CGContextTranslateCTM(ctx, 0, height);
        CGContextScaleCTM(ctx, 1.0f, -1.0f);
        CGContextSetBlendMode(ctx, kCGBlendModeCopy);
        CGContextDrawImage(ctx, rect, image);
        CGContextRelease(ctx);
        CFRelease(image);
        
        self.vsImage.data = (char *)imageData;
        self.vsImage.size = NSMakeSize(width, height);
    }
    */
    
    return self.vsImage;
}

- (void) readMovie:(NSURL *)url atTime:(CMTime) time{
    //[self performSelectorOnMainThread:@selector(updateInfo:) withObject:@"scanning" waitUntilDone:YES];
    
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
                                
                                CMTimeRange timeRange = CMTimeRangeMake(time, kCMTimePositiveInfinity);
                                [self.movieReader setTimeRange:timeRange];
                                
                                if ([self.movieReader startReading]){
                                    [self readNextMovieFrame];
                                    NSLog(@"Video Reading ready");
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
   // NSLog(@"readNextMovieFrame");
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
        //NSLog(@"status is now %ld", self.movieReader.status);
    }
    
}


@end
