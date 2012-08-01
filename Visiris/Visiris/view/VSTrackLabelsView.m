//
//  VSTrackLabelsView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTrackLabelsView.h"

#import "VSTrackLabel.h"

#import "VSCoreServices.h"

@interface VSTrackLabelsView()
@property NSMutableParagraphStyle *paragrapheStyle;
@property NSMutableDictionary *textAttributes;
@end

@implementation VSTrackLabelsView

@synthesize trackLabels = _trackLabels;


- (id)initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation{
    self = [super initWithScrollView:scrollView orientation:orientation];
    if (self) {
        self.trackLabels = [[NSMutableArray alloc] init];
        self.ruleThickness = 40;
        
        
        self.paragrapheStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        self.paragrapheStyle.alignment =NSCenterTextAlignment;
        
        self.textAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               [NSColor blueColor], NSForegroundColorAttributeName,
                               [NSFont boldSystemFontOfSize:10], NSFontAttributeName,
                               self.paragrapheStyle, NSParagraphStyleAttributeName ,
                               nil];
    }
    
    
    
    return self;
}

-(void) drawHashMarksAndLabelsInRect:(NSRect)rect{
    
    for(VSTrackLabel* label in self.trackLabels){
            [self drawLabel:label];
    }
}

-(void) drawLabel:(VSTrackLabel*) trackLabel{
    [[NSColor lightGrayColor] setFill];

    NSRect drawRect = trackLabel.frame;
    drawRect.origin.y -= self.clientView.visibleRect.origin.y;
    NSRectFill(drawRect);
    [trackLabel.name drawInRect:drawRect withAttributes:self.textAttributes];
}

-(void) addTrackLabel:(VSTrackLabel *)aTrackLabel{
    [self.trackLabels addObject:aTrackLabel];
}

@end
