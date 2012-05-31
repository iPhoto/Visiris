//
//  VSQuartzComposerHandover.h
//  VisirisCore
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSCoreHandover.h"

/**
 * The VSCoreHandover is used to handover data from the UI/Model-Part of Visiris to the RenderCore. Besides the data the parent class VSCoreHandover provides, VSQuartzComposerHandover stores the path of Quartz composer file the handover stores the data for.
 */
@interface VSQuartzComposerHandover : VSCoreHandover

/** File path of the quartz composer path the handover stores the data for */
@property NSString* filePath;

/**
 * Inits the VSCoreHandover for the given timestmap with the given attributes
 * @param theAttributes NSDictionary containing the parameters, the VSParemterType property of the VSParameter object is used as Key.
 * @param The timestamp the data is set of
 * @param theFilePath file path of the quartz composer patch
 * @return self
 */
-(id) initWithAttributes:(NSDictionary *)theAttributes forTimestamp:(double)theTimestamp andFilePath:(NSString*) theFilePath;

@end
