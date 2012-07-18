//
//  VSTransformTexture.h
//  VisirisCore
//
//  Created by Scrat on 17/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSTransformTextureManager : NSObject

- (id)initWithContext:(NSOpenGLContext *)context;
- (GLuint)transformTexture:(GLuint)texture atTrack:(NSInteger)trackId withAttributes:(NSDictionary *)attributes withTextureSize:(NSSize)textureSize forOutputSize:(NSSize)outputSize;
- (void)createFBOWithSize:(NSSize) size trackId:(NSInteger) trackId;

@end
