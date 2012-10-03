//
//  VSAudioSourceSupplier.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSAudioSourceSupplier.h"
#import "VSTimelineObject.h"

#import "VSTimelineObject.h"

@implementation VSAudioSourceSupplier


#pragma mark - Methods

- (double)convertToAudioTimestamp:(double)localTimestamp{
    localTimestamp = localTimestamp <= self.timelineObject.sourceDuration ? localTimestamp :  fmod(localTimestamp, self.timelineObject.sourceDuration);
        
    return localTimestamp/1000.0;
}

@end
