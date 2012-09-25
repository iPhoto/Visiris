//
//  VSProjectSettings.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSProjectSettings.h"

@implementation VSProjectSettings

#define DEFAULT_FRAME_RATE 60
#define DEFAULT_FRAME_WIDTH 1280
#define DEFAULT_FRAME_HEIGHT 720

@synthesize frameRate       = _frameRate;
@synthesize frameSize       = _frameSize;
@synthesize projectName     = _projectName;

static VSProjectSettings* sharedProjectSettings = nil;

#pragma mark- Functions

+(VSProjectSettings*)sharedProjectSettings{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedProjectSettings = [[VSProjectSettings alloc] init];
        
    });
    
    return sharedProjectSettings;
}

-(id)init{
    if (self = [super init]) {
        self.frameRate = DEFAULT_FRAME_RATE;
        self.frameSize = NSMakeSize(DEFAULT_FRAME_WIDTH, DEFAULT_FRAME_HEIGHT);
    }
    return self;
}

#pragma mark - Properties

-(float) aspectRatio{
    return self.frameSize.width / self.frameSize.height;
}


@end
