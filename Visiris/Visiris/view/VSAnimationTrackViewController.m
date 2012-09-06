//
//  VSAnimationTimelineTrackViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTrackViewController.h"
#import "VSAnimationTrackView.h"

#import "VSCoreServices.h"

@interface VSAnimationTrackViewController ()

@property VSAnimationTrackView *animationTrackView;

@end

@implementation VSAnimationTrackViewController

-(id) initWithFrame:(NSRect) trackFrame andColor:(NSColor*) trackColor{
    if(self = [super init]){
        self.animationTrackView = [[VSAnimationTrackView alloc]initWithFrame:trackFrame];
        self.view = self.animationTrackView;
        self.animationTrackView.trackColor = trackColor;
    }
    return self;
}

@end
