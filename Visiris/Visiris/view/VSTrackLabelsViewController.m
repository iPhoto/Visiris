//
//  VSTrackLabelsViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTrackLabelsViewController.h"

#import "VSTrackLabel.h"
#import "VSTrackLabelsView.h"

#import "VSCoreServices.h"

@interface VSTrackLabelsViewController ()

@property (strong) VSTrackLabelsView *trackLabelsView;

@end


@implementation VSTrackLabelsViewController
@synthesize trackLabelsView     = _trackLabelsView;

-(id) initWithFrame:(NSRect)frameRect{
    if(self = [self init]){
        [self.trackLabelsView setFrame:frameRect];
    }
    
    return self;
}

-(id) init{
    if(self = [super init]){
        self.trackLabelsView = [[VSTrackLabelsView alloc] init];
        self.view = self.trackLabelsView;
    }
    
    return self;
}

#pragma mark - Methods

-(void) addTrackLabel:(VSTrackLabel *)aTrackLabel{
    [[self.trackLabelsView trackLabels] addObject:aTrackLabel];
    
    [self.trackLabelsView setNeedsDisplay:YES];
}

@end
