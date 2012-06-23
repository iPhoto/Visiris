//
//  VSCoreReceptionist.m
//  VisirisCore
//
//  Created by Andreas Schacherbauer on 5/16/12.
//  Copyright (c) 2012 DevaStation. All rights reserved.
//

#import "VSCoreReceptionist.h"

//@class ;

@implementation VSCoreReceptionist
@synthesize renderCore = _renderCore;
@synthesize delegate=_delegate;

-(id) init{
    if(self = [super init]){
        self.renderCore = [[VSRenderCore alloc] init];
        self.renderCore.delegate = self;
    }
    return self;
}

- (void)renderFrameAtTimestamp:(double)aTimestamp withHandovers:(NSArray *)theHandovers forSize:(NSSize)theFrameSize
{
    //return if Handovers is nil
    if (theHandovers == nil)
        return;
        
    //send the texture 0 to the postprocessor if there is object to render
    if (theHandovers.count < 1) {
        [self renderCore:self.renderCore didFinishRenderingTexture:0 forTimestamp:aTimestamp];
    }
    else {
        [self.renderCore renderFrameOfCoreHandovers:theHandovers forFrameSize:theFrameSize forTimestamp:aTimestamp];
    }
    
}

-(GLuint) createNewTextureForSize:(NSSize) textureSize colorMode:(NSString*) colorMode forTrack:(NSInteger)trackID withType:(VSFileKind)type withOutputSize:(NSSize)size withPath:(NSString *)path{
    return [self.renderCore createNewTextureForSize:textureSize colorMode:colorMode forTrack:trackID withType:type withOutputSize:size withPath:path];
}

-(void) removeTextureForID:(GLuint)anID{
    
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

- (NSOpenGLContext *) openGLContext{
    return _renderCore.openGLContext;
}

@end
