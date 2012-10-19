//
//  VSPlayHead.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPlayHead.h"

@implementation VSPlayHead

@synthesize jumping = _jumping;
-(BOOL) jumping{
    return _jumping;
}

-(void) setJumping:(BOOL)jumping{
    _jumping = jumping;
}

@end
