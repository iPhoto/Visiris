//
//  VSScrollView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 11.09.12.
//
//

#import "VSScrollView.h"

#import "VSCoreServices.h"

@interface VSScrollView()

@property NSRect lastBounds;

@end

@implementation VSScrollView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

-(void) awakeFromNib{
    [self.contentView setPostsBoundsChangedNotifications:YES];
    
    self.lastBounds = self.contentView.bounds;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:self.contentView];
}

-(void) boundsDidChange:(NSNotification*) notification{
    if([self scrollingDelegateRespondsToSelector:@selector(scrollView:changedBoundsFrom:to:)]){
        [self.scrollingDelegate scrollView:self changedBoundsFrom:self.lastBounds to:((NSView*) notification.object).bounds];
    }
    
    self.lastBounds = ((NSView*) notification.object).bounds;
}

-(void) scrollWheel:(NSEvent *)theEvent{
    
    BOOL allowedToScroll = YES;
    
    if([self scrollingDelegateRespondsToSelector:@selector(scrollView:willBeScrolledByScrollWheelEvent:)]){
        allowedToScroll = [self.scrollingDelegate scrollView:self willBeScrolledByScrollWheelEvent:theEvent];
    }
    
    if(allowedToScroll){
        [super scrollWheel:theEvent];
    }
}

-(void) setBoundsOriginWithouthNotifiying:(NSPoint) boundsOrigin{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSViewBoundsDidChangeNotification object:self.contentView];
    [self.contentView setBoundsOrigin:boundsOrigin];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:self.contentView];
}

#pragma mark - Private Methods

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) scrollingDelegateRespondsToSelector:(SEL) selector{
    if(self.scrollingDelegate){
        if([self.scrollingDelegate conformsToProtocol:@protocol(VSScrollViewScrollingDelegate) ]){
            if([self.scrollingDelegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

@end
