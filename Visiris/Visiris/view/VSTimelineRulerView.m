//
//  VSTimelineRulerView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineRulerView.h"

#import "VSCoreServices.h"

@interface VSTimelineRulerView ()
@property int amount;
@property int maxDistance;
@property float currentUnit;
@property int lineHeight;
@property NSMutableParagraphStyle *paragrapheStyle;
@property NSMutableDictionary *textAttributes;
@property NSString *timeFormat;
@property NSRect timecodeRect;
@property float longUnitStrokeLength;
@property float shortUnitStrokeLength;
@property float unitStrokeCenter;
@property NSBezierPath *unitPaths;
@end

@implementation VSTimelineRulerView

@synthesize pixelTimeRatio = _pixelTimeRatio;
@synthesize timecodeRect = _timecodeRect;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}


-(id) initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation{
    if(self = [super initWithScrollView:scrollView orientation:orientation]){
        self.amount = self.maxDistance = 150;
        self.lineHeight = 10;
        self.paragrapheStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        self.paragrapheStyle.alignment =NSCenterTextAlignment;
        self.paragrapheStyle.lineSpacing = self.lineHeight;
        
        self.textAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               [NSColor blueColor], NSForegroundColorAttributeName,
                               [NSFont boldSystemFontOfSize:10], NSFontAttributeName,
                               self.paragrapheStyle, NSParagraphStyleAttributeName ,
                               nil];
        
        
        self.reservedThicknessForMarkers = 50;
        [self setRuleThickness:1];
        
        self.timecodeRect = NSMakeRect(0, 0, self.lineHeight, self.amount);
        
        self.unitPaths = [[NSBezierPath alloc] init];
        self.unitPaths.lineWidth = 0.5;
        
        self.unitStrokeCenter = 25;
        self.longUnitStrokeLength = 16;
        self.shortUnitStrokeLength = 8;
        
    }
    
    return self;
}


-(void) drawHashMarksAndLabelsInRect:(NSRect)rect{
    float offset = 0;
    if(self.scrollView.hasVerticalRuler){
        offset = self.scrollView.verticalRulerView.ruleThickness/2*-1;
    }
    
    DDLogInfo(@"offset: %f",offset);
    
    NSRect visibleRect = self.clientView.visibleRect;
    visibleRect.origin.x += offset;
    
    
    int start =  (u_int)(rect.origin.x  - ((int) (visibleRect.origin.x + rect.origin.x+offset) % self.amount));
    
    rect.size.width = ceil((rect.size.width + (rect.origin.x - start)) / self.amount) * self.amount;
    rect.origin.x = start;
    
    float timeCodeOffset = visibleRect.origin.x+offset;
    
    [self drawRulerInRect:rect timeCodeOffset:timeCodeOffset];
}


-(void) drawRulerInRect:(NSRect) rect timeCodeOffset:(float) timeCodeOffset
{
    [self.unitPaths removeAllPoints];
    
    [[NSColor blackColor] setStroke];

    float strokeSpace = self.amount / 10.0;
    
    [self.unitPaths moveToPoint:NSMakePoint(rect.origin.x, self.unitStrokeCenter)];
    [self.unitPaths lineToPoint:NSMakePoint(NSMaxX(rect), self.unitStrokeCenter)];
    
    int count = NSMaxX(rect) / self.amount;
    
    for(int i = 0; i <= count; i++){
        
        float currentPosition = rect.origin.x+i * self.amount;
        [self addLongUnitStrokeToPathAtLocation:currentPosition];
        
        for(int j= 1; j <= 10; j++){
            if(j!=5)
                [self addShortUnitStrokeToPathAtLocation:currentPosition+j*strokeSpace];
            else
                [self addLongUnitStrokeToPathAtLocation:currentPosition+j*strokeSpace];
            
        }
        
        _timecodeRect.origin.x = currentPosition- self.timecodeRect.size.width / 2;
        
        
        NSString* timecode = [VSFormattingUtils formatedTimeStringFromMilliseconds:(currentPosition+timeCodeOffset)*self.pixelTimeRatio formatString:self.timeFormat];
        [timecode drawInRect:self.timecodeRect withAttributes:self.textAttributes];
        
               
    }
    
    [self.unitPaths stroke];
}

-(void) addShortUnitStrokeToPathAtLocation:(float) location{
    [self.unitPaths moveToPoint:NSMakePoint(location,  self.unitStrokeCenter - self.shortUnitStrokeLength/2)];
    [self.unitPaths lineToPoint:NSMakePoint(location,  self.unitStrokeCenter + self.shortUnitStrokeLength/2)];
}

-(void) addLongUnitStrokeToPathAtLocation:(float) location{
    [self.unitPaths moveToPoint:NSMakePoint(location,  self.unitStrokeCenter - self.longUnitStrokeLength/2)];
    [self.unitPaths lineToPoint:NSMakePoint(location,  self.unitStrokeCenter + self.longUnitStrokeLength/2)];
}



-(void) setPixelTimeRatio:(double)pixelTimeRatio{
    if (_pixelTimeRatio != pixelTimeRatio) {
        _pixelTimeRatio = pixelTimeRatio;

        double tmp = self.maxDistance * pixelTimeRatio;
        
        if(tmp <100){
            self.currentUnit = 100;
        }
        else if(tmp <250){
            self.currentUnit = 250;
        }
        else if(tmp <500){
            self.currentUnit = 500;
        }
        else if(tmp <1000){
            self.currentUnit = 1000;
        }
        else if(tmp <5000){
            self.currentUnit = 5000;
        }
        else if(tmp <10000){
            self.currentUnit = 10000;
        }
        else if(tmp <30000){
            self.currentUnit = 30000;
        }
        else if(tmp <30000){
            self.currentUnit = 30000;
        }
        else if(tmp <60000){
            self.currentUnit = 60000;
        }
        else if(tmp <90000){
            self.currentUnit = 90000;
        }
        else if(tmp <120000){
            self.currentUnit = 120000;
        }
        else if(tmp <150000){
            self.currentUnit = 150000;
        }
        else if(tmp <180000){
            self.currentUnit = 180000;
        }
        else{
            self.currentUnit = 210000;
        }
        
        if(self.currentUnit >= 1000){
            self.timeFormat = @"HH:mm:ss";
        }
        else{
            self.timeFormat = @"HH:mm:ss:tt";
        }
        
        self.amount = self.currentUnit / pixelTimeRatio;
        _timecodeRect.size.width = self.amount;
        
        [self invalidateHashMarks];
    }
}

-(double) pixelTimeRatio{
    return _pixelTimeRatio;
}


@end
