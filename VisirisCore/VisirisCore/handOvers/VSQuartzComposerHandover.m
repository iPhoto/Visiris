//
//  VSQuartzComposerHandover.m
//  VisirisCore
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQuartzComposerHandover.h"

@implementation VSQuartzComposerHandover

@synthesize filePath = _filePath;

-(id) initWithAttributes:(NSDictionary *)theAttributes forTimestamp:(double)theTimestamp andFilePath:(NSString *)theFilePath forId:(NSInteger)theId {
    if(self = [super initWithAttributes:theAttributes forTimestamp:theTimestamp forId:theId]){
        self.filePath = theFilePath;
    }
    return self;
}

@end
