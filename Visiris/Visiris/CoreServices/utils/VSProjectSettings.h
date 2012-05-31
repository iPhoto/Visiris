//
//  VSProjectSettings.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Manages the settings of the current Visirs Project.
 */
@interface VSProjectSettings : NSObject

/** Size of the video-output */
@property NSSize frameSize;

/** Frame-Rate of the output */
@property NSInteger frameRate;

/** Name of the project */
@property NSString *projectName;

/*!
 Returns the singleton Instance
 @return Reference on the Singleton Instance
 */
+(VSProjectSettings*)sharedProjectSettings;
@end
