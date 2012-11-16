//
//  VSEmtpyRuler.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.11.12.
//
//

#import "VSEmtpyRuler.h"

@implementation VSEmtpyRuler

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id) initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation{
    if(self = [super initWithScrollView:scrollView orientation:orientation]){
        self.reservedThicknessForMarkers = 0;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
}

-(void) drawHashMarksAndLabelsInRect:(NSRect)rect{
    
}

@end
