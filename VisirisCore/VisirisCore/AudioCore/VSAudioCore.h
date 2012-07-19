//
//  VSAudioCore.h
//  VisirisCore
//
//  Created by Scrat on 18/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSAudioCore : NSObject

- (void)createAudioPlayerForProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID atTrack:(NSInteger)trackID andFilePath:(NSString *)path;
- (void)playAudioOfHandovers:(NSArray *)handovers atTimeStamp:(double)timeStamp;
- (void)stopPlaying;

@end
