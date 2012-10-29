//
//  VSReferenceCounting.m
//  VisirisCore
//
//  Created by Edwin Guggenbichler on 9/28/12.
//
//

#import "VSReferenceCounting.h"

@interface VSReferenceCounting()

/** The Dictionary which holds the input objects as keys and the reference count is saved as an NSNumberobject */
@property (strong) NSMutableDictionary     *referenceCountingToIDObject;

@end


@implementation VSReferenceCounting


#pragma mark - Init

- (id)init{
    if (self = [super init]) {
        self.referenceCountingToIDObject = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark - Methods

- (void)incrementReferenceOfKey:(id)key
{
    NSNumber *object = [self.referenceCountingToIDObject objectForKey:key];
    
    if (object) {
        //increment
        NSInteger currentCounter = object.integerValue;
        currentCounter++;
        [self.referenceCountingToIDObject setValue:[NSNumber numberWithInteger:currentCounter] forKey:key];
    }
    else {
        [self.referenceCountingToIDObject setValue:[NSNumber numberWithInteger:1] forKey:key];
    }
}

- (BOOL)decrementReferenceOfKey:(id)key
{
    NSNumber *object = [self.referenceCountingToIDObject objectForKey:key];

    if (object == nil) {
        NSLog(@"ERROR decrementing a object which isn't existing");
    }
    else {
        NSInteger currentCounter = object.integerValue;
        currentCounter--;
        
        if (currentCounter == 0) {
            [self.referenceCountingToIDObject removeObjectForKey:key];
            return NO;
        }
        else {
            [self.referenceCountingToIDObject setValue:[NSNumber numberWithInteger:currentCounter] forKey:key];
        }
    }
    return YES;
}

- (BOOL)isObjectExisting:(id)object
{
    if([self.referenceCountingToIDObject objectForKey:object])
        return YES;
    else
        return NO;
}

- (void)printDebugLog{
    for (id key in self.referenceCountingToIDObject) {
        NSLog(@"value: %@, References: %@", key, [self.referenceCountingToIDObject objectForKey:key]);
    }
}

@end
