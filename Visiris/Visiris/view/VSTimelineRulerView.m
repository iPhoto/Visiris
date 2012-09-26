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
/** Distance between one timecode label to the other, neccessary to compute how many timecode-partitions have to be updated after the rulerview was scrolled */
@property double currentRulerPartitionWidth;

/** If currentRulerPartitionWidth is bigger than maximalRulerPartitionWidth the unit is changed */
@property double maximalRulerPartitionWidth;

/** Widht of one partition in milliseconds */
@property double currentMillisecondsPerPartition;

/** Space between the lines of the raster. E.g.: currentRulerPartitionWidth / 10 */
@property double spaceBetweenRasterLines;

/** Line-height of the timecodeLabel*/
@property int timeCodeLineHeight;
 
/** Paragraph style of the timecode label */
@property (strong) NSMutableParagraphStyle *paragrapheStyle;

/** text attributes of the timecode label */
@property (strong) NSMutableDictionary *textAttributes;

/** Format string for the timecode like definend VSFormattingUtils*/
@property (strong) NSString *timeFormat;

/** Rect of the timecode label */
@property NSRect timecodeRect;

/** Lenght of the longer Unit stokes in the raster used for neuralgic points like 0, 5, 10 */
@property float longUnitStrokeLength;

/** lenght of the shorter unit strokes in the raster */
@property float shortUnitStrokeLength;

/** Vertical-center of the strokes in the raster */
@property float unitStrokeCenter;

/** storing all paths before drawing */
@property (strong) NSBezierPath *unitPaths;
@end

@implementation VSTimelineRulerView

@synthesize pixelTimeRatio = _pixelTimeRatio;

#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}


-(id) initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation{
    if(self = [super initWithScrollView:scrollView orientation:orientation]){
        
        [self initTextStyle];
        
        [self initAppearance];
    }
    
    return self;
}

/**
 * Sets the base settings of the rulerview, the length of the unit strokes and the frame for drawing the timecodes
 */
-(void) initAppearance{
    self.reservedThicknessForMarkers = 50;
    [self setRuleThickness:1];
    
    self.timecodeRect = NSMakeRect(0, 0, self.timeCodeLineHeight, self.currentRulerPartitionWidth);
    
    self.unitPaths = [[NSBezierPath alloc] init];
    self.unitPaths.lineWidth = 0.5;
    
    self.unitStrokeCenter = 25;
    self.longUnitStrokeLength = 16;
    self.shortUnitStrokeLength = 8;
}


/**
 * Sets the appearance of the text showing the timecode
 */
-(void) initTextStyle{
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
}

#pragma mark - NSRulerView

-(void) drawHashMarksAndLabelsInRect:(NSRect)rect{
    
    if(self.scrollView.hasVerticalRuler){
        self.originOffset =  self.scrollView.verticalRulerView.ruleThickness;
    }
    
    NSRect visibleRect = self.clientView.visibleRect;
    
    double width = visibleRect.origin.x + rect.origin.x - self.originOffset;
    double start =  rect.origin.x  - fmod(width , self.currentRulerPartitionWidth);
    
    //number of partition that need to be drawn to fill the requested rect
    int numberOfPartitions =  ceil((rect.size.width + (rect.origin.x - start)) / self.currentRulerPartitionWidth);
    
    //neccessary to show the correct timecode
    double timeCodeOffset = visibleRect.origin.x - self.originOffset;
    
    
    [self.unitPaths removeAllPoints];
    [[NSColor blackColor] setStroke];
    
    [self.unitPaths moveToPoint:NSMakePoint(start, self.unitStrokeCenter)];
    [self.unitPaths lineToPoint:NSMakePoint(start+numberOfPartitions*self.currentRulerPartitionWidth, self.unitStrokeCenter)];
    
    
    for(int i = 0; i <= numberOfPartitions; i++){
        double currentPosition = start+i * self.currentRulerPartitionWidth;
        
        [self drawPartitionsRasterAtStartingFrom:currentPosition];
        
        _timecodeRect.origin.x = currentPosition- self.timecodeRect.size.width / 2;
        NSString* timecode = [VSFormattingUtils formatedTimeStringFromMilliseconds:(currentPosition+timeCodeOffset)*self.pixelTimeRatio formatString:self.timeFormat];
        [timecode drawInRect:self.timecodeRect withAttributes:self.textAttributes];
    }
    
    [self.unitPaths stroke];
}

#pragma mark - Private Methods


/**
 * Draws the raster for one Partition starting from the given position
 * @param position x-Position where the drawing of the raster is started at
 */
-(void) drawPartitionsRasterAtStartingFrom:(float) position{
    [self addLongUnitStrokeToPathAtLocation:position];
    
    for(int i= 1; i <= 10; i++){
        if(i!=5)
            [self addShortUnitStrokeToPathAtLocation:position+i*self.spaceBetweenRasterLines];
        else
            [self addLongUnitStrokeToPathAtLocation:position+i*self.spaceBetweenRasterLines];
        
    }
}

/*
 * Draws one smaller unit stroke at the given position.
 */
-(void) addShortUnitStrokeToPathAtLocation:(float) location{
    [self.unitPaths moveToPoint:NSMakePoint(location,  self.unitStrokeCenter - self.shortUnitStrokeLength/2)];
    [self.unitPaths lineToPoint:NSMakePoint(location,  self.unitStrokeCenter + self.shortUnitStrokeLength/2)];
}

/*
 * Draws one longer unit stroke at the given position. Longer strokes are used for units like 0, 5, 10
 */
-(void) addLongUnitStrokeToPathAtLocation:(float) location{
    [self.unitPaths moveToPoint:NSMakePoint(location,  self.unitStrokeCenter - self.longUnitStrokeLength/2)];
    [self.unitPaths lineToPoint:NSMakePoint(location,  self.unitStrokeCenter + self.longUnitStrokeLength/2)];
}

/**
 * Computes the current width of the partitions according to the current pixelTimeRatio
 */
-(void) computePartitionWidthAccordingToPixelTimeRatio{
    int tmp = ceil(self.maximalRulerPartitionWidth * self.pixelTimeRatio);
    
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
    
    self.currentRulerPartitionWidth = self.currentMillisecondsPerPartition / self.pixelTimeRatio;
    
    _timecodeRect.size.width = self.currentRulerPartitionWidth;
    self.spaceBetweenRasterLines = self.currentRulerPartitionWidth / RASTER_LINES_PER_PARTITION;
    [self invalidateHashMarks];
    
}

#pragma mark - Properties

-(void) setPixelTimeRatio:(double)pixelTimeRatio{
    if (_pixelTimeRatio != pixelTimeRatio) {
        _pixelTimeRatio = pixelTimeRatio;
        
        [self computePartitionWidthAccordingToPixelTimeRatio];
    }
}

-(double) pixelTimeRatio{
    return _pixelTimeRatio;
}

-(CGFloat) ruleThickness{
    return [super ruleThickness] + self.reservedThicknessForMarkers;
}

@end
