//
//  VSReferenceCounting.h
//  VisirisCore
//
//  Created by Edwin Guggenbichler on 9/28/12.
//
//

#import <Foundation/Foundation.h>

@interface VSReferenceCounting : NSObject

- (void)incrementReferenceOfKey:(id)object;

- (BOOL)decrementReferenceOfKey:(id)object;

- (BOOL)isObjectExisting:(id)object;

- (void)printDebugLog;

@end
