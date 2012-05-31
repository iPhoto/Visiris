//
//  VSQuartzComposerSourceSupplier.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSSourceSupplier.h"

/**
 * Supplier for VSTimelineObjects with VSQuartzComposerSource
 */

@interface VSQuartzComposerSourceSupplier : VSSourceSupplier


/**
 * Returns the file path of the QuartzComposer path the timelineObejct represents.
 * @return File path of the quartz composer patch
 */
-(NSString*) getQuartzComposerPatchFilePath;

@end
