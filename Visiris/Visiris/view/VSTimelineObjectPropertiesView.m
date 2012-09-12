//
//  VSTimelineObjectPropertiesView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.08.12.
//
//

#import "VSTimelineObjectPropertiesView.h"

#import "VSCoreServices.h"

@implementation VSTimelineObjectPropertiesView


-(void) setFrame:(NSRect)frameRect{
    NSRect oldFrame = self.frame;
    [super setFrame:frameRect];
    
    if(self.resizingDelegate){
        if([self.resizingDelegate conformsToProtocol:@protocol(VSViewResizingDelegate) ]){
            if([self.resizingDelegate respondsToSelector:@selector(frameOfView:wasSetFrom:to:)]){
                [self.resizingDelegate frameOfView:self
                                        wasSetFrom:oldFrame
                                                to:self.frame];
            }
        }
    }
}

@end
