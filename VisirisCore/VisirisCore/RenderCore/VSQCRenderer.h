//
//  VSQCRenderer.h
//  VisirisCore
//
//  Created by Scrat on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSQCRenderer : NSObject
@property (readonly, assign) NSInteger  timeLineObjectId;
@property (readonly, assign) NSInteger  trackId;
@property (assign) NSSize               size;

- (id)initWithPath:(NSString *)path withSize:(NSSize)size withContext:(NSOpenGLContext *)context withPixelformat:(NSOpenGLPixelFormat *)format withTrackID:(NSInteger)trackid;

- (GLuint)renderAtTme:(double)time;
- (GLuint) texture;
- (void) setPublicInputsWithValues:(NSDictionary*) inputValues;
@end
