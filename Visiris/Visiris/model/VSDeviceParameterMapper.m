//
//  VSDeviceAnimation.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSDeviceParameterMapper.h"

@implementation VSDeviceParameterMapper

@synthesize device = _device;

#pragma mark - Init

-(id) initWithDevice:(VSDevice *)aDevice{
    if(self = [self init]){
        self.device  =aDevice;
    }
    
    return self;
}

@end
