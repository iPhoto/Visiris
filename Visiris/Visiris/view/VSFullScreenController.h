//
//  VSSecondScreen.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>

@interface VSFullScreenController : NSObject

- (id)initWithContext:(NSOpenGLContext *)context atScreen:(NSInteger)screenID;

- (void)updateWithTexture:(GLuint)texture;

@end
