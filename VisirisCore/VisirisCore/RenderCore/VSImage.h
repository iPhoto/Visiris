//
//  VSImage.h
//  VisirisCore
//
//  Created by Scrat on 12/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSImage : NSObject
@property (assign) NSSize   size;
@property (assign) char*    data;
@property (assign) BOOL     needsUpdate;

@end
