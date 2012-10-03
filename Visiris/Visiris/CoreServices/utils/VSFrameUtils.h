//
//  VSFrameUtils.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 24.09.12.
//
//

#import <Foundation/Foundation.h>
/**
 * Utilty class providing Functions for calculations concerning NSRects
 **/
@interface VSFrameUtils : NSObject

/**
 * Computes the midPoint of the given frame
 * @param frame NSRect the midPoint will be computed for
 * @return Midpoint of the given NSRect as NSPoint
 */
+(NSPoint) midPointOfFrame:(NSRect) frame;

/**
 * Returns the maximal correct proportional Rect in a rect. 
 * @param rect The input rect
 * @param superViewRect The superview of the rect
 * @return maximal Rect
 */
+ (NSRect)maxProportionalRectinRect:(NSRect)rect inSuperView:(NSRect)superViewRect;

@end
