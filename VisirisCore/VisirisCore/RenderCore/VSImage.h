//
//  VSImage.h
//  VisirisCore
//
//  Created by Scrat on 12/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Abstract Basic Image class. Optimized for OpenGLTextures usage.
 */
@interface VSImage : NSObject

/** The Size of the Texture */
@property (assign) NSSize   size;

/** Plain PixelData in RGBA */
@property (assign) char*    data;

/** True if the content has changed so the Opengl knows when to replace its own content */
@property (assign) BOOL     needsUpdate;

@end
