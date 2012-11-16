//
//  VSAnimationTimelineContentView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTimelineScrollViewDocumentView.h"

#import "VSCoreServices.h"

@implementation VSAnimationTimelineScrollViewDocumentView

-(id) init{
    if(self = [super initWithFrame:NSZeroRect]){
        
    }
    
    return self;
}

-(void) awakeFromNib{
    [super setViewsProperties];
    [self setAutoresizingMask:NSViewWidthSizable];
    
//    [self.layer setBackgroundColor:[[NSColor redColor] CGColor]];
}

@end
