//
//  VSQuartzCompositionReader.m
//  Visiris
//
//  Created by Scrat on 26/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQuartzCompositionReader.h"
#import <Quartz/Quartz.h>


@interface VSQuartzCompositionReader()
@property (strong) QCComposition    *qcComposition;

@end

@implementation VSQuartzCompositionReader
@synthesize qcComposition = _qcComposition;

- (id)initWithFilepath:(NSString *)path{
    if (self = [super init]) {
        self.qcComposition = [QCComposition compositionWithFile:path];
        
        for (id iterator in self.qcComposition.inputKeys) {
            NSLog(@"value: %@", iterator);
        }
        
        for (id key in self.qcComposition.attributes) {
            NSLog(@"key: %@, value: %@", key, [self.qcComposition.attributes objectForKey:key]);        
        }
        
    }
    return self;
}

@end
