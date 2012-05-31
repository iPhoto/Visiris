//
//  VSUndoManager.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSUndoManager : NSObject<NSWindowDelegate>

@property NSUndoManager *undoManager;

+(VSUndoManager*)sharedManager;

- (void)registerVSUndoWithTarget:(id)target selector:(SEL)selector object:(id)anObject;


@end
