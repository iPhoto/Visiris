//
//  VSFrameUtils.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 24.09.12.
//
//

#import "VSFrameUtils.h"

@implementation VSFrameUtils

+(NSPoint) midPointOfFrame:(NSRect) frame{
    return NSMakePoint(frame.origin.x + frame.size.width / 2.0f, frame.origin.y + frame.size.height / 2.0f);
}

@end
