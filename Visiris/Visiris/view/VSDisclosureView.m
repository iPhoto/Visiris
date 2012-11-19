//
//  VSDisclosableView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.11.12.
//
//

#import "VSDisclosureView.h"
#import "VSDisclosureContentView.h"
#import "VSCoreServices.h"

@interface VSDisclosureView(){
    float contentViewHeight;
    bool collapsed;
    bool animationRunning;
}

@end

@implementation VSDisclosureView

#pragma mark -
#pragma mark Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    DDLogInfo(@"arschloch: %@",keyPath);
    if([keyPath isEqualToString:@"frame"]){
        
        [self updateContentViewSize];
    }
    else if([keyPath isEqualToString:@"subviews"]){
        NSInteger kind = [[change valueForKey:@"kind"] intValue];
        
        switch (kind) {
            case NSKeyValueChangeInsertion:
            {
                if(![[change valueForKey:@"notificationIsPrior"] boolValue]){
                    NSArray *newSubviews = [[object valueForKey:keyPath] objectsAtIndexes:[change  objectForKey:@"indexes"]];
                    
                    for(NSView *subView in newSubviews){
                        [subView addObserver:self
                                  forKeyPath:@"frame"
                                     options:0
                                     context:nil];
                    }
                    
                    //                    [self updateContentViewSize];
                }
                break;
            }
            case NSKeyValueChangeRemoval:
            {
                if([[change valueForKey:@"notificationIsPrior"] boolValue]){
                    NSArray *removedSubviews = [[object valueForKey:keyPath] objectsAtIndexes:[change  objectForKey:@"indexes"]];
                    
                    for(NSView *subView in removedSubviews){
                        [subView removeObserver:self forKeyPath:@"frame"];
                    }
                    
                    //                    [self updateContentViewSize];
                }
                else{
                    
                }
                break;
            }
            default:
                break;
        }
    }
}

-(void) awakeFromNib{
    
    
    [disclosureButton setTarget:self];
    [disclosureButton setAction:@selector(disclosureButtonStateDidChange:)];
    
    [self setAutoresizingMask:NSViewWidthSizable];
    [self setAutoresizesSubviews:YES];
    
    [self.contentView setAutoresizingMask:NSViewWidthSizable];
    [self.contentView setAutoresizesSubviews:YES];
    
    CABasicAnimation *animation = [CABasicAnimation animation];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.delegate = self;
	[self setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"frameSize"]];
    
    collapsed = !disclosureButton.state;
    animationRunning = NO;

    contentView.delegate = self;
}

-(BOOL) isFlipped{
    return YES;
}

-(NSSize) intrinsicContentSize{
    NSSize intrinsicContentSize = controlsHolder.frame.size;
    
    if(!collapsed){
        
        intrinsicContentSize.height += self.contentView.intrinsicContentSize.height;
    }
    
    return intrinsicContentSize;
}

-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    collapsed = !collapsed;
    animationRunning = NO;
    
    if(collapsed){
        if([self delegateRespondsToSelector:@selector(didHideContentOfDisclosureView:)]){
            [delegate didHideContentOfDisclosureView:self];
        }
    }
    else{
        if([self delegateRespondsToSelector:@selector(didShowContentOfDisclosureView:)]){
            [delegate didShowContentOfDisclosureView:self];
        }
    }
}

-(void) animationDidStart:(CAAnimation *)anim{
    animationRunning = YES;
}

#pragma mark -
#pragma mark IBAction
- (IBAction)disclosureButtonStateDidChange:(NSButton*)sender{
    
    if(YES){//collapsed != sender.state){
        if(sender.state){
            [self showContentView];
        }
        else{
            [self hideContentView];
        }
    }
}

#pragma mark -
#pragma mark VSDisclosureContentViewDelegate Implementation

-(void) contentDidChange{
    if(!animationRunning){
        [self updateContentViewSize];
    }
}

#pragma mark -
#pragma mark Private Methods

-(void) updateContentViewSize{

    [self.contentView setFrameSize:contentView.intrinsicContentSize];
    [self setFrameSize:NSMakeSize(self.frame.size.width, controlsHolder.frame.size.height+contentView.intrinsicContentSize.height)];

    if([self delegateRespondsToSelector:@selector(contentSizeDidChangeOfDisclosureView:)]){
        [delegate contentSizeDidChangeOfDisclosureView:self];
    }
}

-(void) showContentView{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.2];
    
    if([self delegateRespondsToSelector:@selector(willShowContentOfDisclosureView:)]){
        [delegate willShowContentOfDisclosureView:self];
    }
    
    NSSize newContentFrameSize = self.frame.size;
    newContentFrameSize.height += contentViewHeight;
    [self.animator setFrameSize:newContentFrameSize];
    
    NSSize newSuperFrameSize = self.superview.frame.size;
    newSuperFrameSize.height += contentViewHeight;
    [self.superview.animator setFrameSize:newSuperFrameSize];
    
    if(nextView){
        NSPoint newOrigin = nextView.frame.origin;
        newOrigin.y += contentViewHeight;
        [[nextView animator] setFrameOrigin:newOrigin];
    }
    
    [NSAnimationContext endGrouping];
}

-(void) hideContentView{
    contentViewHeight = self.contentView.frame.size.height;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.2];
    
    if([self delegateRespondsToSelector:@selector(willHideContentOfDisclosureView:)]){
        [delegate willHideContentOfDisclosureView:self];
    }
    
    NSSize newContentFrameSize = self.frame.size;
    newContentFrameSize.height = controlsHolder.frame.size.height;
    [self.animator setFrameSize:newContentFrameSize];
    
    NSSize newSuperFrameSize = self.superview.frame.size;
    newSuperFrameSize.height -= contentViewHeight;
    [self.superview.animator setFrameSize:newSuperFrameSize];
    
    if(nextView){
        NSPoint newOrigin = nextView.frame.origin;
        newOrigin.y -= contentViewHeight;
        [[nextView animator] setFrameOrigin:newOrigin];
    }
    
    [NSAnimationContext endGrouping];
}

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(delegate){
        if([delegate conformsToProtocol:@protocol(VSDisclosureViewDelegate)]){
            if([delegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark -
#pragma mark Properties

//-(NSView*) contentView{
//    return contentView;
//}

-(float) controlAreaHeight{
    return self.frame.size.height - self.contentView.frame.size.height;
}

-(NSView*) contentView{
    return contentView;
}


@end
