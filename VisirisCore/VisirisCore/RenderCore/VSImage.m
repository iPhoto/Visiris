//
//  VSImage.m
//  VisirisCore
//
//  Created by Scrat on 12/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSImage.h"

@implementation VSImage
@synthesize data = _data;
@synthesize size = _size;
@synthesize needsUpdate = _needsUpdate;


#pragma Mark - Init

-(id)init{
    if (self = [super init]) {
        _needsUpdate = YES;
        _data = NULL;
    }
    return self;
}

@end
