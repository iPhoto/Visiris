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

/**
 * Inits VSPostProcessor and conencts it with the given VSPlaybackController
 * @param thePlaybackController  VSPlaybackController the VSPostProcessor calls when the rendering of the texture has finished by the core
 * @return self
 */
-(id) initWithPlaybackController:(VSPlaybackController*) thePlaybackController;

@end
