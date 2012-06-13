//
//  VSTexture.h
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSImage;

@interface VSTexture : NSObject
@property (readonly, assign) GLuint     texture;
@property (readonly, assign) NSSize     size;
@property (readonly, assign) NSInteger  timeLineObjectId;

- (id)initEmptyTextureWithSize:(NSSize) size;
- (void)replaceContent:(VSImage *) theImage timeLineObjectId:(NSInteger) timeLineObjectId;
- (void)bind;
- (void)unbind;
- (void)deleteTexture;

@end
