//
//  VSFrameUtils.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 24.09.12.
//
//

#import "VSFrameUtils.h"
#import "VSProjectSettings.h"

@implementation VSFrameUtils

+(NSPoint) midPointOfFrame:(NSRect) frame{
    return NSMakePoint(frame.origin.x + frame.size.width / 2.0f, frame.origin.y + frame.size.height / 2.0f);
}

+ (NSRect)maxProportionalRectinRect:(NSRect)rect inSuperView:(NSRect)superViewRect{
    float aspectRatio = [VSProjectSettings sharedProjectSettings].aspectRatio;
    float proportionalHeight = rect.size.width / aspectRatio;
    
    if(proportionalHeight<rect.size.height){
        rect.size.height = proportionalHeight;
    }
    
    rect.size.width = rect.size.height * aspectRatio;
    
    rect.origin.x = (superViewRect.size.width - rect.size.width) / 2.0f;
    rect.origin.y = (superViewRect.size.height - rect.size.height) / 2.0f;
    
    return rect;
}

@end
