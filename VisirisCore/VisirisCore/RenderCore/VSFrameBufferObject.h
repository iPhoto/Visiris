//
//  VSFrameBufferObject.h
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSFrameBufferObject : NSObject
@property (readonly, assign) GLuint     texture;
@property (readonly, assign) NSSize     size;

-(id) init;
-(id)initWithSize:(NSSize)size;

-(void) bind;
-(void) unbind;
-(void) resize:(NSSize)size;


@end
