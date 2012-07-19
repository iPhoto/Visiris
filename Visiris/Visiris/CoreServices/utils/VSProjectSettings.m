//
//  VSProjectSettings.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSProjectSettings.h"

@implementation VSProjectSettings
@synthesize frameRate = _frameRate;
@synthesize frameSize = _frameSize;
@synthesize projectName = _projectName;

static VSProjectSettings* sharedProjectSettings = nil;

#pragma mark- Functions

+(VSProjectSettings*)sharedProjectSettings{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedProjectSettings = [[VSProjectSettings alloc] init];
        
    });
    
    return sharedProjectSettings;
}

#pragma mark - Properties

-(float) aspectRatio{
    return self.frameSize.width / self.frameSize.height;
}


@end
