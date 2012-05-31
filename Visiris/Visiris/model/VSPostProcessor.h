//
//  VSPostProcessor.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VisirisCore/VSCoreReceptionist.h"

@class VSPlaybackController;

/**
 * VSPostProcessor is called when the core has finished rendering a frame
 */
@interface VSPostProcessor : NSObject <VSCoreReceptionistDelegate>


-(id) initWithPlaybackController:(VSPlaybackController*) thePlaybackController;

@end
