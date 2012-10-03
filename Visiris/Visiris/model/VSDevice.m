//
//  VSDevice.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSDevice.h"

#import "VSDeviceParameter.h"

@implementation VSDevice

-(id) initWithID:(NSString*) UUID andName:(NSString*) name{
    if(self = [super init]){
        self.name = name;
        self.ID = UUID;
        
        self.parameters = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void) addParametersObject:(VSDeviceParameter *)object{
    [self.parameters  setObject:object forKey:object.oscPath];
}

@end
