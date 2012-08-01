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

#define RASTER_LINES_PER_PARTITION 10

@property double currentRulerPartitionWidth;
@property double maximalRulerPartitionWidth;
@property double currentMillisecondsPerPartition;
@property double spaceBetweenRasterLines;
@property int timeCodeLineHeight;
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
        self.currentRulerPartitionWidth = self.maximalRulerPartitionWidth = 150;
        self.timeCodeLineHeight = 10;
        self.paragrapheStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        self.paragrapheStyle.alignment =NSCenterTextAlignment;
        self.paragrapheStyle.lineSpacing = self.timeCodeLineHeight;
        
        self.textAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               [NSColor blueColor], NSForegroundColorAttributeName,
                               [NSFont boldSystemFontOfSize:10], NSFontAttributeName,
                               self.paragrapheStyle, NSParagraphStyleAttributeName ,
                               nil];
        
        
        self.reservedThicknessForMarkers = 50;
        [self setRuleThickness:1];
        
        self.timecodeRect = NSMakeRect(0, 0, self.timeCodeLineHeight, self.currentRulerPartitionWidth);
        
        self.unitPaths = [[NSBezierPath alloc] init];
        self.unitPaths.lineWidth = 0.5;
        
        self.unitStrokeCenter = 25;
        self.longUnitStrokeLength = 16;
        self.shortUnitStrokeLength = 8;
        
    }
    
    return self;
}


-(void) drawHashMarksAndLabelsInRect:(NSRect)rect{
    
    if(self.scrollView.hasVerticalRuler){
        self.originOffset =  self.scrollView.verticalRulerView.ruleThickness;
    }
    
    
    NSRect visibleRect = self.clientView.visibleRect;
    
    double width = visibleRect.origin.x + rect.origin.x - self.originOffset;
    double start =  rect.origin.x  - fmod(width , self.currentRulerPartitionWidth);
    double timeCodeOffset = visibleRect.origin.x - self.originOffset;
    
    int numberOfPartitions =  ceil((rect.size.width + (rect.origin.x - start)) / self.currentRulerPartitionWidth);

    [self.unitPaths removeAllPoints];
    
    [[NSColor blackColor] setStroke];
    
    
    [self.unitPaths moveToPoint:NSMakePoint(start, self.unitStrokeCenter)];
    [self.unitPaths lineToPoint:NSMakePoint(start+numberOfPartitions*self.currentRulerPartitionWidth, self.unitStrokeCenter)];

    
    for(int i = 0; i <= numberOfPartitions; i++){
        
        double currentPosition = start+i * self.currentRulerPartitionWidth;
        
        [self drawPartitionsRasterAtPosition:currentPosition];
        
        _timecodeRect.origin.x = currentPosition- self.timecodeRect.size.width / 2;
        NSString* timecode = [VSFormattingUtils formatedTimeStringFromMilliseconds:(currentPosition+timeCodeOffset)*self.pixelTimeRatio formatString:self.timeFormat];
        [timecode drawInRect:self.timecodeRect withAttributes:self.textAttributes];
        
        
    }
    
    [self.unitPaths stroke];
}

-(void) drawPartitionsRasterAtPosition:(float) position{
    [self addLongUnitStrokeToPathAtLocation:position];
    
    for(int i= 1; i <= 10; i++){
        if(i!=5)
            [self addShortUnitStrokeToPathAtLocation:position+i*self.spaceBetweenRasterLines];
        else
            [self addLongUnitStrokeToPathAtLocation:position+i*self.spaceBetweenRasterLines];
        
    }
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
        
        int tmp = ceil(self.maximalRulerPartitionWidth * pixelTimeRatio);
        
        if(tmp<1000){
            self.currentMillisecondsPerPartition = ceil(tmp/100.0) * 100;
        }
        else if(tmp < 10000){
            self.currentMillisecondsPerPartition = ceil(tmp/5000.0) * 5000;
        }
        else{
            self.currentMillisecondsPerPartition = ceil(tmp/30000.0) * 30000;
        }
        
        
        if(self.currentMillisecondsPerPartition >= 1000){
            self.timeFormat = @"HH:mm:ss";
        }
        else{
            self.timeFormat = @"HH:mm:ss:tt";
        }
        
        self.currentRulerPartitionWidth = self.currentMillisecondsPerPartition / pixelTimeRatio;
        
        _timecodeRect.size.width = self.currentRulerPartitionWidth;
        self.spaceBetweenRasterLines = self.currentRulerPartitionWidth / RASTER_LINES_PER_PARTITION;
        [self invalidateHashMarks];
    }
}

-(double) pixelTimeRatio{
    return _pixelTimeRatio;
}


@end
