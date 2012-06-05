//
//  VSTexture.h
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSTexture : NSObject
@property (readonly, assign) GLuint     texture;

-(id)initWithNSImage:(NSImage *)theImage;
-(id)initWithName:(NSString *)name;
- (id)initWithNSImage:(NSImage *) inimage WithSize: (NSSize)size;

-(void)bind;
-(void)unbind;
-(void)deleteTexture;

@end
