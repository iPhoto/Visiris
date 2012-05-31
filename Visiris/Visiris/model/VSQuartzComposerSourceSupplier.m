//
//  VSQuartzComposerSourceSupplier.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQuartzComposerSourceSupplier.h"
#import "VSTimelineObject.h"
#import "VSTimelineObjectSource.h"

@implementation VSQuartzComposerSourceSupplier

-(NSString*) getQuartzComposerPatchFilePath{
    return self.timelineObject.sourceObject.filePath;
}

@end
