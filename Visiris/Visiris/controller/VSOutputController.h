//
//  VSOutputController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 26.09.12.
//
//

#import <Foundation/Foundation.h>

@class VSPlaybackController;


@protocol VSOpenGLOutputDelegate <NSObject>

-(void) showTexture:(GLuint)texture;

@end


@interface VSOutputController : NSObject

@property (readonly) double             refreshPeriod;
@property VSPlaybackController          *playbackController;
@property (strong) NSOpenGLPixelFormat  *pixelFormat;
@property (nonatomic, assign) NSSize    fullScreenSize;
@property (nonatomic, assign) NSSize    previewSize;

#pragma mark - Functions

+(VSOutputController*)sharedOutputController;


#pragma mark - Methods

/**
 * Called when VSPlaybackController has received the Texture for the timestamp
 * @param theTexture GLuint defining the newly rendered texture.
 * @param theTimestamp Timestamp the texture was rendered for
 */
-(void) texture:(GLuint) theTexture isReadyForTimestamp:(double) theTimestamp;

/**
 * Called when the Playhead of the timeline the VSPlaybackController started to be scrubbed around the timeline
 * @param theTimestamp Current position of the Playhead.
 */
-(void) didStartScrubbingAtTimestamp:(double) aTimestamp;

/**
 * Called when the Playhead of the timeline the VSPlaybackController stopped scrubbing
 * @param theTimestamp Current position of the Playhead.
 */
-(void) didStopScrubbingAtTimestamp:(double) aTimestamp;

-(void) startPlayback;

-(void) stopPlayback;

-(NSOpenGLContext*) registerAsOutput:(id<VSOpenGLOutputDelegate>) output;

-(void) unregisterOutput:(id<VSOpenGLOutputDelegate>) output;

-(void) connectWithOpenGLContext:(NSOpenGLContext*) openGLContext;

- (void)toggleFullScreen;

@end
