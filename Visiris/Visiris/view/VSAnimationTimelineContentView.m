//
//  VSAnimationTimelineContentView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTimelineContentView.h"

#import "VSCoreServices.h"

@implementation VSAnimationTimelineContentView

-(id) init{
    if(self = [super initWithFrame:NSZeroRect]){
        
    }
    
    return self;
}

-(void) awakeFromNib{
    [super setViewsProperties];
}

-(void) drawRect:(NSRect)dirtyRect{
    [[NSColor blueColor] setFill];
    
    NSRectFill(dirtyRect);
}


@end
