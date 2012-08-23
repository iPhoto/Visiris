//
//  VSCoreReceptionist.m
//  VisirisCore
//
//  Created by Andreas Schacherbauer on 5/16/12.
//  Copyright (c) 2012 DevaStation. All rights reserved.
//

#import "VSCoreReceptionist.h"
#import "VSAudioCore.h"
#import "VSCoreHandover.h"
#import "VSFrameCoreHandover.h"
#import "VSQuartzComposerHandover.h"
#import "VSAudioCoreHandover.h"

@interface VSCoreReceptionist()

@property (strong) VSAudioCore   *audioCore;

@end


@implementation VSCoreReceptionist

@synthesize renderCore  = _renderCore;
@synthesize delegate    = _delegate;
@synthesize audioCore   = _audioCore;

-(id) init{
    if(self = [super init]){
        self.renderCore = [[VSRenderCore alloc] init];
        self.audioCore  = [[VSAudioCore alloc] init];
        self.renderCore.delegate = self;
    }
    return self;
}

- (void)renderFrameAtTimestamp:(double)aTimestamp withHandovers:(NSArray *)theHandovers forSize:(NSSize)theFrameSize withPlayMode:(VSPlaybackMode)playMode
{
    //return if Handovers is nil
    if (theHandovers == nil)
        return;
        
    //send the texture 0 to the postprocessor if there is object to render
    if (theHandovers.count < 1) {
        [self renderCore:self.renderCore didFinishRenderingTexture:0 forTimestamp:aTimestamp];
    }
    else {
        
        NSMutableArray *frameArray = [[NSMutableArray alloc] init];
        NSMutableArray *audioArray = [[NSMutableArray alloc] init];
        
        for(VSCoreHandover *coreHandover in theHandovers){
            
            if ([coreHandover isKindOfClass:[VSFrameCoreHandover class]] || [coreHandover isKindOfClass:[VSQuartzComposerHandover class]]){         
                [frameArray addObject:coreHandover];
            }else if ([coreHandover isKindOfClass:[VSAudioCoreHandover class]]) {
                [audioArray addObject:coreHandover];
            }
        }
        
        if (frameArray.count > 0) {
            [self.renderCore renderFrameOfCoreHandovers:frameArray forFrameSize:theFrameSize forTimestamp:aTimestamp];
        }
        
        if (audioArray.count > 0) {
            
            if (playMode == VSPlaybackModePlaying ||
                playMode == VSPlaybackModeScrubbing) {
                [self.audioCore playAudioOfHandovers:audioArray atTimeStamp:aTimestamp];
            }else
                if (playMode == VSPlaybackModeJumping ||
                playMode == VSPlaybackModeStanding) {
                [self.audioCore stopPlaying];
            }
        }
        
    }
    
}

-(GLuint) createNewTextureForSize:(NSSize) textureSize colorMode:(NSString*) colorMode forTrack:(NSInteger)trackID withType:(VSFileKind)type withOutputSize:(NSSize)size withPath:(NSString *)path{
    return [self.renderCore createNewTextureForSize:textureSize colorMode:colorMode forTrack:trackID withType:type withOutputSize:size withPath:path];
}

- (void)createNewAudioPlayerWithProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID forTrack:(NSInteger)trackId andFilePath:(NSString *)filepath{

    [self.audioCore createAudioPlayerForProjectItemID:projectItemID withObjectItemID:objectItemID atTrack:trackId andFilePath:filepath];
}

- (void)removeTextureForID:(GLuint)anID{
    NSLog(@"TODOOOOO (removeTexture)");
}

#pragma mark - RenderCoreDelegate impl.

- (void)renderCore:(VSRenderCore *)theRenderCore didFinishRenderingTexture:(GLuint)theTexture forTimestamp:(double)theTimestamp{
    if (self.delegate) { 
        if([self.delegate conformsToProtocol:@protocol(VSCoreReceptionistDelegate) ]){
            if ([self.delegate respondsToSelector:@selector(coreReceptionist:didFinishedRenderingFrameAtTimestamp:withResultingTexture:)]){
                [self.delegate coreReceptionist:self didFinishedRenderingFrameAtTimestamp:theTimestamp withResultingTexture:theTexture];
            }
        }
    }
}

- (NSOpenGLContext *)openGLContext{
    return _renderCore.openglContext;
}

- (void)stopPlaying{
    [self.audioCore stopPlaying];
}

@end
