//
//  VSDisclosureContentView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.11.12.
//
//

#import "VSDisclosureContentView.h"

#import "VSCoreServices.h"

@interface VSDisclosureContentView(){
    BOOL flag;
}

@end

@implementation VSDisclosureContentView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        flag = YES;
    }
    
    return self;
}

#pragma mark -
#pragma mark NSView

-(void) drawRect:(NSRect)dirtyRect{
    [[NSColor disclosureViewConteViewColor] setFill];
    
    NSRectFill(dirtyRect);
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"frame"]){
        if(flag)
            [self updateContentViewSize];
    }

}

-(void) didAddSubview:(NSView *)subview{
    [subview addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [self updateContentViewSize];
}
-(BOOL) isFlipped{
    return YES;
}
-(void) willRemoveSubview:(NSView *)subview{
    [subview removeObserver:self forKeyPath:@"frame"];
    
    [self updateContentViewSize];
}

-(void) updateContentViewSize{
    flag = NO;
    if([self delegateRespondsToSelector:@selector(contentDidChange)]){
        [self.delegate contentDidChange];
    }
    flag=YES;
}

-(NSSize) intrinsicContentSize{
    float totalHeight = 0.0f;
    
    NSSize intrinsicContentSize = NSMakeSize(self.frame.size.width, 0);
    
    for(NSView *subview in self.subviews){
        if(NSMaxY(subview.frame) > totalHeight){
            totalHeight = NSMaxY(subview.frame);
        }
    }
    
    intrinsicContentSize.height = totalHeight;
    
    return intrinsicContentSize;
}

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSDisclosureContentViewDelegate)]){
            if([self.delegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

@end
