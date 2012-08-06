//
//  VSTrackLabelsView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTrackLabelsRulerView.h"

#import "VSTrackLabel.h"

#import "VSCoreServices.h"

@interface VSTrackLabelsRulerView()
@property NSMutableParagraphStyle *paragrapheStyle;
@property NSMutableDictionary *textAttributes;
@end

@implementation VSTrackLabelsRulerView

@synthesize trackLabels = _trackLabels;

#pragma mark - Init

- (id)initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation{
    self = [super initWithScrollView:scrollView orientation:orientation];
    if (self) {
        self.trackLabels = [[NSMutableArray alloc] init];
        self.ruleThickness = 40;
        
        [self initTextStyle];
        
    }
    
    
    
    return self;
}

/**
 * Sets the text style for the names of the tracks shown in the ruler
 */
-(void) initTextStyle{
    self.paragrapheStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    self.paragrapheStyle.alignment =NSCenterTextAlignment;
    
    self.textAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                           [NSColor blueColor], NSForegroundColorAttributeName,
                           [NSFont boldSystemFontOfSize:10], NSFontAttributeName,
                           self.paragrapheStyle, NSParagraphStyleAttributeName ,
                           nil];
}


#pragma mark - NSRulverView
//TODO: don't draw all labels all the time
-(void) drawHashMarksAndLabelsInRect:(NSRect)rect{
    
    for(VSTrackLabel* label in self.trackLabels){
        [self drawLabel:label];
    }
}

#pragma mark - Methods

-(void) addTrackLabel:(VSTrackLabel *)aTrackLabel{
    [self.trackLabels addObject:aTrackLabel];
}

#pragma mark - Private Methods

/**
 * Draws the given VSTrackLabel on the view
 * @param trackLabel VSTrackLable to be drawn
 */
-(void) drawLabel:(VSTrackLabel*) trackLabel{
    [[NSColor lightGrayColor] setFill];
    
    NSRect drawRect = trackLabel.frame;
    drawRect.origin.y -= self.clientView.visibleRect.origin.y;
    NSRectFill(drawRect);
    [trackLabel.name drawInRect:drawRect withAttributes:self.textAttributes];
}

@end
