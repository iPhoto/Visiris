//
//  VSReferenceCounting.h
//  VisirisCore
//
//  Created by Edwin Guggenbichler on 9/28/12.
//
//

#import <Foundation/Foundation.h>

/**
 * VSReferenceCounting is counting the references of every objects which is once incremented.
 */
@interface VSReferenceCounting : NSObject

/**
 * Increments the reference of an Object.
 * @param object The object can be any type.
 */
- (void)incrementReferenceOfKey:(id)object;

/**
 * Decrements the reference of an object. When the object is not existing then an error message is logged.
 * @param object The object itself.
 * @return YES when the decrement has not reached zero - NO otherwise.
 */
- (BOOL)decrementReferenceOfKey:(id)object;

/**
 * Checks if object gets reference counted
 * @param object The object itself
 * @return YES when object is existing - NO otherwise
 */
- (BOOL)isObjectExisting:(id)object;

/**
 * Simple debug output of the reference counted object including the actual reference count of each object.
 */
- (void)printDebugLog;

@end
