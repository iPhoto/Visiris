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
#import "VSFileKind.h"
#import "VSVideoCoreHandover.h"

@interface VSCoreReceptionist()

@property (strong) VSAudioCore          *audioCore;
@property (assign) BOOL                 isPlaying;
@property (strong) NSMutableDictionary  *fileTypeToObjectID;
@property (strong) NSMutableArray       *willRemoveTimelineObjects;

@end


@implementation VSCoreReceptionist

@synthesize renderCore  = _renderCore;
@synthesize delegate    = _delegate;
@synthesize audioCore   = _audioCore;

- (id)initWithSize:(NSSize)size{
    if(self = [super init]){
        self.renderCore = [[VSRenderCore alloc] initWithSize:size];
        self.audioCore  = [[VSAudioCore alloc] init];
        self.fileTypeToObjectID = [[NSMutableDictionary alloc] init];
        self.willRemoveTimelineObjects = [[NSMutableArray alloc] init];
        self.renderCore.delegate = self;
        self.isPlaying = NO;
    }
    return self;
}

- (void)renderFrameAtTimestamp:(double)aTimestamp withHandovers:(NSArray *)theHandovers forSize:(NSSize)theFrameSize withPlayMode:(VSPlaybackMode)playMode
{
//    NSLog(@"%f",aTimestamp);
    self.isPlaying = YES;
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
            if ([coreHandover isKindOfClass:[VSFrameCoreHandover class]] ||
                [coreHandover isKindOfClass:[VSQuartzComposerHandover class]])
            {
                [frameArray addObject:coreHandover];
                
                if ([coreHandover isKindOfClass:[VSVideoCoreHandover class]])
                {
                    VSVideoCoreHandover *temp = (VSVideoCoreHandover *)coreHandover;
                    if (temp.hasAudio)
                        [audioArray addObject:coreHandover];
                }
            }
            else
                if ([coreHandover isKindOfClass:[VSAudioCoreHandover class]])
                    [audioArray addObject:coreHandover];
        }
        
        if (frameArray.count > 0) {
            if (self.isPlaying) {
                [self.renderCore renderFrameOfCoreHandovers:frameArray forFrameSize:theFrameSize forTimestamp:aTimestamp];
            }
        }
        
        if (audioArray.count > 0) {
            
            if (playMode == VSPlaybackModePlaying ||
                playMode == VSPlaybackModeScrubbing) {
                if (self.isPlaying) {
                    [self.audioCore playAudioOfHandovers:audioArray atTimeStamp:aTimestamp];
                }
            }else
                if (playMode == VSPlaybackModeJumping ||
                playMode == VSPlaybackModeNone) {
                [self.audioCore stopPlaying];
            }
        }
    }
    
    //this is called at the and so no one is interrupting the playback
    for (NSNumber *number in self.willRemoveTimelineObjects) {
        [self removeTimelineobjectWithID:number.integerValue];
    }
    [self.willRemoveTimelineObjects removeAllObjects];
}

- (void)createNewTextureForSize:(NSSize) textureSize colorMode:(NSString*) colorMode forTrack:(NSInteger)trackID withType:(VSFileKind)type withOutputSize:(NSSize)size withPath:(NSString *)path withObjectItemID:(NSInteger)objectItemID{

    [self.renderCore createNewTextureForSize:textureSize colorMode:colorMode forTrack:trackID withType:type withOutputSize:size withPath:path withObjectItemID:(NSInteger)objectItemID];

    [self.fileTypeToObjectID setObject:[NSNumber numberWithInt:type] forKey:[NSNumber numberWithInteger:objectItemID]];

//    [self printDebugLog];
}

- (void)createNewAudioPlayerWithProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID forTrack:(NSInteger)trackId andFilePath:(NSString *)filepath{
    [self.audioCore createAudioPlayerForProjectItemID:projectItemID withObjectItemID:objectItemID atTrack:trackId andFilePath:filepath];
    
    NSNumber *temp = [self.fileTypeToObjectID objectForKey:[NSNumber numberWithInteger:objectItemID]];
    
    if (temp == nil) {
        [self.fileTypeToObjectID setObject:[NSNumber numberWithInt:VSFileKindAudio] forKey:[NSNumber numberWithInteger:objectItemID]];
    }
    
//    [self printDebugLog];
}

- (void)willRemoveTimelineobjectWithID:(NSInteger)anID{
    [self.willRemoveTimelineObjects addObject:[NSNumber numberWithInteger:anID]];
}

- (void)removeTimelineobjectWithID:(NSInteger)anID{
        
    NSNumber *type = [self.fileTypeToObjectID objectForKey:[NSNumber numberWithInteger:anID]];

    switch (type.intValue) {
        case VSFileKindAudio:
            [self.audioCore deleteTimelineobjectID:anID];
            break;
        case VSFileKindImage:
            [self.renderCore deleteTextureFortimelineobjectID:anID];
            break;
        case VSFileKindVideo:
            [self.renderCore deleteTextureFortimelineobjectID:anID];
            [self.audioCore deleteTimelineobjectID:anID];
            break;
        case VSFileKindQuartzComposerPatch:
            [self.renderCore deleteQCPatchForTimelineObjectID:anID];
            break;
        default:
            break;
    }
    
    [self.fileTypeToObjectID removeObjectForKey:[NSNumber numberWithInteger:anID]];

//    [self printDebugLog];
}

- (void)printDebugLog{
    NSLog(@"###############################################");
    NSLog(@"##########D-E-B-U-G - L-O-G - C-O-R-E##########");
    NSLog(@"###############################################");
    [self.renderCore printDebugLog];
    [self.audioCore printDebugLog];
    NSLog(@"=====Preprocesser ID to Filetypemapping=====");
    for (id objectID in self.fileTypeToObjectID) {
        NSLog(@"objectID: %@, filetype: %@", objectID, [self.fileTypeToObjectID objectForKey:objectID]);
    }
    NSLog(@"###############################################");
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
    self.isPlaying = NO;
    [self.audioCore stopPlaying];
}

@end
