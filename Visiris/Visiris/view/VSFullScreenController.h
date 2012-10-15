//
//  VSSecondScreen.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>

#import "VSOutputController.h"

@interface VSFullScreenController : NSResponder<VSOpenGLOutputDelegate>

- (id)init;

-(void) toggleFullScreenForScreen:(NSInteger) screenID;

+ (NSInteger)numberOfScreensAvailable;

+ (NSInteger)mainScreen;

@end
