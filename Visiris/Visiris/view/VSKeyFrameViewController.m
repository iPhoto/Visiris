//
//  VSKeyFrameViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.09.12.
//
//

#import "VSKeyFrameViewController.h"

#import "VSKeyFrameView.h"
#import "VSKeyFrame.h"

@interface VSKeyFrameViewController ()

@end 


@implementation VSKeyFrameViewController

@synthesize pixelTimeRatio = _pixelTimeRatio;

- (id)initWithKeyFrame:(VSKeyFrame *)keyFrame withSize:(NSSize)size forPixelTimeRatio:(double)pixelTimeRatio{
    if(self = [super init]){
        self.keyFrame = keyFrame;
        self.size = size;
        NSRect keyFrameFrame = NSMakeRect(0, 0, size.width, size.height);
        self.view = self.keyFrameView = [[VSKeyFrameView alloc] initWithFrame:keyFrameFrame];
        self.pixelTimeRatio = pixelTimeRatio;
    }
    
    return self;
}

-(double) timestampForPixelValue:(double) pixelPosition{
    return pixelPosition * self.pixelTimeRatio;
}

-(double) pixelForTimestamp:(double) timestamp{
    return timestamp / self.pixelTimeRatio;
}

#pragma mark - Properties

-(void) setPixelTimeRatio:(double)pixelTimeRatio{
    _pixelTimeRatio = pixelTimeRatio;
    
    NSPoint newOrigin = NSMakePoint([self pixelForTimestamp:self.keyFrame.timestamp] - self.view.frame.size.width / 2.0 , 20);
    
    [self.keyFrameView setFrameOrigin:newOrigin];
}

-(double) pixelTimeRatio{
    return _pixelTimeRatio;
}

@end
