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

@end
