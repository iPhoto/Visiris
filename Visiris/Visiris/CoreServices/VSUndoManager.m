//
//  VSUndoManager.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSUndoManager.h"

@interface VSUndoManager()



@end

@implementation VSUndoManager

@synthesize undoManager = _undoManager;

/** Instance of the Singleton */
static VSUndoManager* sharedUndoManager = nil;



#pragma mark- Init

-(id) init{
    if(self = [super init]){
    }
    
    return self;
}





#pragma mark- Functions

+(VSUndoManager*)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedUndoManager = [[VSUndoManager alloc] init];
        
    });
    
    return sharedUndoManager;
}


- (void) registerVSUndoWithTarget:(id)target selector:(SEL)selector object:(id)anObject{
    [self.undoManager registerUndoWithTarget:target selector:selector object:anObject];
}

-(NSUndoManager*) windowWillReturnUndoManager:(NSWindow *)window{
    return self.undoManager;
}

@end
