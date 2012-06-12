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

-(id)initEmptyTextureWithSize:(NSSize) size;
-(id)initWithNSImage:(NSImage *)theImage;
-(id)initWithName:(NSString *)name;

- (void)replaceContent:(VSImage *) theImage;

-(void)bind;
-(void)unbind;
-(void)deleteTexture;

@end
