//
//  VSTextureManager.h
//  VisirisCore
//
//  Created by Scrat on 06/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSTexture;

@interface VSTextureManager : NSObject

- (GLuint)createTextureWithSize:(NSSize) size;
- (VSTexture *)getVSTextureForTexId:(GLuint) texId;

@end
