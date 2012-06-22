//
//  VSTimelineObjectViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectViewController.h"

#import "VSTimelineObjectProxy.h"
#import "VSTimelineObjectViewIntersection.h"

#import "VSCoreServices.h"

@interface VSTimelineObjectViewController()
@property double pixelTimeRatio;
@end


@implementation VSTimelineObjectViewController

#define VIEWS_HIGHLIGHTED_ZPOSITION 20
#define VIEWS_DEFAULT_ZPOSITION 10

@synthesize pixelTimeRatio                  = _pixelTimeRatio;
@synthesize delegate                        = _delegate;
@synthesize timelineObjectProxy             = _timelineObjectProxy;
@synthesize temporary                       = _temporary;
@synthesize moving                          = _moving;
@synthesize intersectedTimelineObjectViews  = _intersectedTimelineObjectViews;


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
    
    self.intersectedTimelineObjectViews = [[NSMutableDictionary alloc] init];
    if([self.view isKindOfClass:[VSTimelineObjectView class]]){
        ((VSTimelineObjectView*) self.view).delegate = self;
    }
    
    [self initObservers];
}

-(void) initObservers{
    [self.timelineObjectProxy addObserver:self forKeyPath:@"selected" options:0 context:nil];
    [self.timelineObjectProxy addObserver:self forKeyPath:@"duration" options:0 context:nil];
    [self.timelineObjectProxy addObserver:self forKeyPath:@"startTime" options:0 context:nil];  
}

#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"selected"]){
        if(self.view){
            if([self.view isKindOfClass:[VSTimelineObjectView class]]){
                BOOL selected = [[object valueForKey:keyPath] boolValue];
                if(((VSTimelineObjectView*)self.view).selected != selected){
                    ((VSTimelineObjectView*)self.view).selected = selected;
                    
                    if(selected){
                        
                        if([self delegateRespondsToSelector:@selector(timelineObjectProxyWasSelected:)]){
                            [self.delegate timelineObjectProxyWasSelected:self.timelineObjectProxy];
                        }
                    }
                    else {
                        if([self delegateRespondsToSelector:@selector(timelineObjectProxyWasUnselected:)]){
                            [self.delegate timelineObjectProxyWasUnselected:self.timelineObjectProxy];
                        }
                        
                    }
                    
                    [self.view setNeedsDisplay:YES];
                }
            }
        }
    }
    
    if([keyPath isEqualToString:@"duration"] || [keyPath isEqualToString:@"startTime"]){
        [self setViewsFrameAccordingToTimelineObject];
    }
}


#pragma mark - VSTimelineObjectViewDelegate implementation

-(void) timelineObjectViewWasClicked:(VSTimelineObjectView *)timelineObjectView withModifierFlags:(NSUInteger)modifierFlags {
    
    BOOL exclusiveSelection = !(modifierFlags & NSCommandKeyMask);
    
    if(!self.timelineObjectProxy.selected){
        if([self delegateRespondsToSelector:@selector(timelineObjectProxyWillBeSelected:exclusively:)]){
            [self.delegate timelineObjectProxyWillBeSelected:self.timelineObjectProxy exclusively:exclusiveSelection];
        }
    }
}

-(NSPoint) timelineObjectViewWillBeDragged:(VSTimelineObjectView *)timelineObjectView fromPosition:(NSPoint)oldPosition toPosition:(NSPoint)newPosition forMousePosition:(NSPoint)currentMousePosition{
    if([self delegateRespondsToSelector:@selector(timelineObjectWillBeDragged:fromPosition:toPosition:forMousePosition:)]){
        return [self.delegate timelineObjectWillBeDragged:self fromPosition:oldPosition toPosition:newPosition forMousePosition:currentMousePosition];
    }
    
    return newPosition;
}

-(void) timelineObjectViewWasDragged:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectWasDragged:)]){
        [self.delegate timelineObjectWasDragged:self];
    }
}



-(BOOL) timelineObjectViewWillStartDragging:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectWillStartDragging:)]){
        return [self.delegate timelineObjectWillStartDragging:self];
    }
    
    return NO;
}

-(void)timelineObjectDidStopDragging:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectDidStopDragging:)]){
        [self.delegate timelineObjectDidStopDragging:self];
    }
    [self setViewsFrameAccordingToTimelineObject];
    [self.view setNeedsDisplay:YES];
}

-(BOOL) timelineObjectWillStartResizing:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectWillStartResizing:)]){
        return [self.delegate timelineObjectWillStartResizing:self];
    }
    
    return NO;
}

-(NSRect) timelineObjectWillResize:(VSTimelineObjectView *)timelineObjectView fromFrame:(NSRect)oldFrame toFrame:(NSRect)newFrame{
    if([self delegateRespondsToSelector:@selector(timelineObjectWillResize:oldFrame:)]){
        return [self.delegate timelineObjectWillResize:self fromFrame:oldFrame toFrame:newFrame];
    }
    
    return newFrame;
}

-(void) timelineObjectDidStopResizing:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectDidStopResizing:)]){
        [self.delegate timelineObjectDidStopResizing:self];
    }
}

-(void) timelineObjectViewWasResized:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectProxyWasResized:)]){
        [self.delegate timelineObjectProxyWasResized:self];
    }
}

#pragma mark - Methods

-(void) changePixelTimeRatio:(double)newPixelTimeRatio{
    if(newPixelTimeRatio != self.pixelTimeRatio){
        self.pixelTimeRatio = newPixelTimeRatio;
        [self setViewsFrameAccordingToTimelineObject];
    }
}

-(void) intersectsTimelineObjectView:(VSTimelineObjectViewController *)timelineObjectViewController intersects:(NSRect)intersectionRect{
    
    NSNumber *key = [NSNumber numberWithInt: timelineObjectViewController.timelineObjectProxy.timelineObjectID];
    
    VSTimelineObjectViewIntersection *intersection = [self.intersectedTimelineObjectViews objectForKey:key];
    
    if(intersection){
        intersection.intersectionRect = intersectionRect;
    }
    else {
        intersection = [[VSTimelineObjectViewIntersection alloc] initWithIntersectedTimelineObejctView:timelineObjectViewController intersectedAt:intersectionRect];
        
        [self.intersectedTimelineObjectViews setObject:intersection forKey:key];
    }
}

-(void) removeIntersectionWith:(VSTimelineObjectViewController *)timelineObjectViewController{
    NSNumber *key = [NSNumber numberWithInt: timelineObjectViewController.timelineObjectProxy.timelineObjectID];
    
    [self.intersectedTimelineObjectViews removeObjectForKey:key];
}

#pragma mark - Private Methods

/**
 * Sets the frame of the view according to timelineObjectProxies startTime and duration. 
 */
-(void) setViewsFrameAccordingToTimelineObject{
    
    if(self.view){
        NSRect frame = self.view.frame;
        frame.origin.x = self.timelineObjectProxy.startTime / self.pixelTimeRatio;
        frame.size.width = self.timelineObjectProxy.duration / self.pixelTimeRatio;
        frame.size.height = self.view.frame.size.height;
        frame.origin.y = 0;
        
        [self.view setFrame:frame];
        [self.view setNeedsDisplay:YES];
    }
}

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSTimelineObjectControllerDelegate) ]){
            if([self.delegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - Propertes

-(BOOL) temporary{
    return _temporary;
}

-(void) setTemporary:(BOOL)temporary{
    if([self.view isKindOfClass:[VSTimelineObjectView class]]){
        ((VSTimelineObjectView*) self.view).temporary = temporary;
        if(temporary != _temporary){
            [self.view setNeedsDisplay:YES];
            
            if(temporary){
                [self.view.layer setZPosition:VIEWS_HIGHLIGHTED_ZPOSITION];
            }
            else {
                [self.view.layer setZPosition:VIEWS_DEFAULT_ZPOSITION];
            }
        }
        
        _temporary = temporary;
    }
}

-(void) setMoving:(BOOL)moving{
    if(moving != _moving){
        if([self.view isKindOfClass:[VSTimelineObjectView class]]){
            ((VSTimelineObjectView*) self.view).moving = moving;
            
            if(moving){
                [self.view.layer setZPosition:VIEWS_HIGHLIGHTED_ZPOSITION];
            }
            else {
                [self.view.layer setZPosition:VIEWS_DEFAULT_ZPOSITION];
            }
            
            [self.view setNeedsDisplay:YES];
            
        }
    }
    _moving = moving;
}

-(BOOL) moving{
    return _moving;
}

@end
