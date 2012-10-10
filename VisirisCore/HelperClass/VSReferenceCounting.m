//
//  VSReferenceCounting.m
//  VisirisCore
//
//  Created by Edwin Guggenbichler on 9/28/12.
//
//

#import "VSReferenceCounting.h"

@interface VSReferenceCounting()

@property (strong) NSMutableDictionary     *referenceCountingToIDObject;

@end


@implementation VSReferenceCounting
@synthesize referenceCountingToIDObject     = _referenceCountingToIDObject;

- (id)init{
    if (self = [super init]) {
        self.referenceCountingToIDObject = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)incrementReferenceOfKey:(id)key{
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

//bool: yes means everything alright. No means the object reached zero.
- (BOOL)decrementReferenceOfKey:(id)key{
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
