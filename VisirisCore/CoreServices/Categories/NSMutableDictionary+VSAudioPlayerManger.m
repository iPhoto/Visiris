//
//  NSMutableDictionary+VSAudioPlayerManger.m
//  VisirisCore
//
//  Created by Scrat on 18/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSMutableDictionary+VSAudioPlayerManger.h"

@implementation NSMutableDictionary (VSAudioPlayerManger)

- (id)playerCollectionForTrackID:(NSInteger)trackID
{
    return [self objectForKey:[NSNumber numberWithInteger:trackID]];
}

@end
