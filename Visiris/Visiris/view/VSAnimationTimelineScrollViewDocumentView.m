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
}

-(void) drawRect:(NSRect)dirtyRect{
    [[NSColor blueColor] setFill];
    
    NSRectFill(dirtyRect);
}

-(void) setFrame:(NSRect)frameRect{

    if(frameRect.size.height > 840.0){
        DDLogInfo(@"its bigger");
    }
    
    [super setFrame:frameRect];
    
}

@end
