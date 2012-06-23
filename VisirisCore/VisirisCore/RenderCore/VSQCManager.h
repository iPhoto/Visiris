//
//  VSQCPManager.h
//  VisirisCore
//
//  Created by Scrat on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSQCRenderer;

@interface VSQCManager : NSObject

- (GLuint)createQCRendererWithSize:(NSSize) size withTrackId:(NSInteger) trackId withPath:(NSString *)path withContext:(NSOpenGLContext *)context withFormat:(NSOpenGLPixelFormat *)format;
- (VSQCRenderer *)getQCRendererForId:(GLuint) texId;

@end
