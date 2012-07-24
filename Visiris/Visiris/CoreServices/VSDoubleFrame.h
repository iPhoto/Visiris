//
//  VSDoubleFrame.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <Foundation/Foundation.h>

#ifndef Visiris_VSDoubleFrame_h
#define Visiris_VSDoubleFrame_h
typedef struct{
    double width;
    double height;
    double x;
    double y;
} VSDoubleFrame;



NS_INLINE VSDoubleFrame VSMakeFrame(double x, double y, double width, double height){
    VSDoubleFrame frame;
    frame.x = x;
    frame.y = y;
    frame.width = width;
    frame.height = height;
    
    return frame;
}

NS_INLINE NSRect NSRectFromVSDoubleFrame(VSDoubleFrame doubleFrame){
    return NSIntegralRect( NSMakeRect(doubleFrame.x, doubleFrame.y, doubleFrame.width, doubleFrame.height));
}

NS_INLINE bool VSEqualDoubleFrame(VSDoubleFrame frameOne, VSDoubleFrame frameTwo){
    if(frameOne.x != frameTwo.x)
        return false;
    if(frameOne.y != frameTwo.y)
        return false;
    if(frameOne.width != frameTwo.width)
        return false;
    if(frameOne.height != frameTwo.height)
        return false;
    
    return true;
}

NS_INLINE NSString* NSStringFromVSDoubleFrame(VSDoubleFrame doubleFrame){
    return [NSString stringWithFormat:@"(%f,%f) (%f,%f)",doubleFrame.x, doubleFrame.y,doubleFrame.width,doubleFrame.height];
}


#endif

