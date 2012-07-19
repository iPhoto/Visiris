//
//  VSAudioPlayerManager.h
//  VisirisCore
//
//  Created by Scrat on 18/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSAudioPlayerManager : NSObject

- (void)createAudioPlayerForProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID atTrack:(NSInteger)trackID andFilePath:(NSString *)path;
- (void)playAudioOfObjectID:(NSInteger)objectID atTime:(double)time atVolume:(float)volume;
- (void)stopPlaying;

@end
