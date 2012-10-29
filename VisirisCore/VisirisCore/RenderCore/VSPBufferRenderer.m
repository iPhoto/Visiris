/*
 File: PBufferRenderer.m
 Abstract: PBufferRenderer class.
 Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */

#import "VSPBufferRenderer.h"

@implementation VSPBufferRenderer

@synthesize pixelBuffer         = _pixelBuffer;
@synthesize	pixelBufferContext  = _pixelBufferContext;
@synthesize	renderer            = _renderer;
@synthesize	textureContext      = _textureContext;
@synthesize texture             = _texture;


#pragma mark - Init

- (id) initWithCompositionPath:(NSString*)path textureWidth:(unsigned)width textureHeight:(unsigned)height openGLContext:(NSOpenGLContext*)context withTexture:(NSNumber *)texture
{    
    self.texture = [texture intValue];
    
	NSOpenGLPixelFormatAttribute	attributes[] = {
        kCGLPFAAccelerated,
        kCGLPFANoRecovery,
        kCGLPFADoubleBuffer,
        kCGLPFAColorSize, 24,
        kCGLPFADepthSize, 16,
        0
    };
    
	NSOpenGLPixelFormat* format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
	
	//Check parameters - Rendering at sizes smaller than 16x16 will likely produce garbage and we only support 2D or RECT textures
	if(![path length] || (width < 16) || (height < 16) || (context == nil)) {
		return nil;
	}
	
	if(self = [super init]) {
		//Keep the target OpenGL context around
        _textureContext = context;
        
		//Create the OpenGL pBuffer to render into
		_pixelBuffer = [[NSOpenGLPixelBuffer alloc] initWithTextureTarget:GL_TEXTURE_2D textureInternalFormat:GL_RGBA textureMaxMipMapLevel:0 pixelsWide:width pixelsHigh:height];
		if(_pixelBuffer == nil) {
			NSLog(@"Cannot create OpenGL pixel buffer");
			return nil;
		}
		
		//Create the OpenGL context to use to render in the pBuffer (with color and depth buffers) - It needs to be shared to ensure both contexts have identical virtual screen lists
		_pixelBufferContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:_textureContext];
		if(_pixelBufferContext == nil) {
			NSLog(@"Cannot create OpenGL context");
			return nil;
		}
		
		//Attach the OpenGL context to the pBuffer (make sure it uses the same virtual screen as the primary OpenGL context)
		[_pixelBufferContext setPixelBuffer:_pixelBuffer cubeMapFace:0 mipMapLevel:0 currentVirtualScreen:[_textureContext currentVirtualScreen]];
		
		//Create the QuartzComposer Renderer with that OpenGL context and the specified composition file
		_renderer = [[QCRenderer alloc] initWithOpenGLContext:_pixelBufferContext pixelFormat:format file:path];
		if(_renderer == nil) {
			NSLog(@"Cannot create QCRenderer");
			return nil;
		}
		
        //Update the texture immediately
		[self updateTextureForTime:0.0];
	}
	
	return self;
}

#pragma mark - Methods

- (void) _updateTextureOnTargetContext{
    [_textureContext makeCurrentContext];
		
	//Bind the texture and update its contents
    glBindTexture(GL_TEXTURE_2D, _texture);
	[_textureContext setTextureImageToPixelBuffer:_pixelBuffer colorBuffer:GL_FRONT];
}

- (BOOL)updateTextureForTime:(NSTimeInterval)time{

    [_pixelBufferContext makeCurrentContext];
	BOOL							success;
	NSOpenGLPixelBuffer*			pBuffer;
	
	//Make sure the virtual screen for the pBuffer and its rendering context match the target one
	if([_textureContext currentVirtualScreen] != [_pixelBufferContext currentVirtualScreen]) {
		pBuffer = [[NSOpenGLPixelBuffer alloc] initWithTextureTarget:GL_TEXTURE_2D textureInternalFormat:GL_RGBA textureMaxMipMapLevel:0 pixelsWide:[_pixelBuffer pixelsWide] pixelsHigh:[_pixelBuffer pixelsHigh]];
		if(pBuffer) {
			[_pixelBufferContext clearDrawable];
			_pixelBuffer = pBuffer;
			[_pixelBufferContext setPixelBuffer:_pixelBuffer cubeMapFace:0 mipMapLevel:0 currentVirtualScreen:[_textureContext currentVirtualScreen]];
		}
		else {
			NSLog(@": Failed recreating OpenGL pixel buffer");
			return NO;
		}
	}
	
	//Render a frame from the composition at the specified time in the pBuffer
	success = [_renderer renderAtTime:time arguments:nil];
	
	//IMPORTANT: Make sure all OpenGL rendering commands were sent to the pBuffer OpenGL context
	glFlushRenderAPPLE();
	
	//Update the texture in the target OpenGL context from the contents of the pBuffer
	[self _updateTextureOnTargetContext];
		
	return success;
}

- (GLuint)textureName{
    return _texture;
}

@end
