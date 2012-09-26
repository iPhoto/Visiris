//
//  VSOpenGLView.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Cocoa/Cocoa.h>

@interface VSOpenGLView : NSView

@property (strong) NSOpenGLContext          *openGLContext;
@property (strong) NSOpenGLPixelFormat      *pixelFormat;
@property (assign) GLuint                   texture;

- (void)setOpenGLWithSharedContext:(NSOpenGLContext *)openGLContext;
- (void)drawView;

@end
