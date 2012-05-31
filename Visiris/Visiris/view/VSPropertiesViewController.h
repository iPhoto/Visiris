//
//  VSPropertiesViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VSPropertiesViewController : NSViewController


#pragma mark - Init 

-(id) initWithDefaultNib;

/** View which holds the properties subviews */
@property (weak) IBOutlet NSView *contentView;

@end
