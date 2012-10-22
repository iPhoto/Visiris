//
//  VSSecondScreen.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>

#import "VSOutputController.h"

#import "VSViewKeyDownDelegate.h"

@interface VSFullScreenController : NSResponder<VSOpenGLOutputDelegate, VSViewKeyDownDelegate>

- (id)initWithOutputController:(VSOutputController*) outputController;

-(void) toggleFullScreenForScreen:(NSInteger) screenID;

+ (NSInteger)numberOfScreensAvailable;

+ (NSInteger)mainScreen;

@end
