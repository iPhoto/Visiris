//
//  VSTimelineObjectViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectViewController.h"

#import "VSTimelineObjectProxy.h"

#import "VSCoreServices.h"


@implementation VSTimelineObjectViewController

@synthesize delegate = _delegate;

@synthesize timelineObjectProxy = _timelineObjectProxy;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSTimelinObjectView";

-(id) initWithDefaultNib{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

-(void) awakeFromNib{
    if([self.view isKindOfClass:[VSTimelineObjectView class]]){
        ((VSTimelineObjectView*) self.view).delegate = self;
    }
    
    [self.timelineObjectProxy addObserver:self forKeyPath:@"selected" options:0 context:nil];
    
}

#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"selected"]){
        if(self.view){
            if([self.view isKindOfClass:[VSTimelineObjectView class]]){
                BOOL selected = [[object valueForKey:keyPath] boolValue];
                if(((VSTimelineObjectView*)self.view).selected != selected){
                    ((VSTimelineObjectView*)self.view).selected = selected;
                    [self.view setNeedsDisplay:YES];
                }
            }
        }
    }
}

#pragma mark - VSTimelineObjectViewDelegate implementation

-(void) timelineObjectViewWasClicked:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectProxyWillBeSelected:)]){
        [self.delegate timelineObjectProxyWillBeSelected:self.timelineObjectProxy];
    }
}

-(void) timelineObjectViewWasDragged:(VSTimelineObjectView *)timelineObjectView toPosition:(NSPoint)newPosition{
    
}

#pragma mark - Private Methods

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if([self.delegate conformsToProtocol:@protocol(VSTimelineObjectControllerDelegate) ]){
        if([self.delegate respondsToSelector: selector]){
            return YES;
        }
    }
    
    return NO;
}



@end
