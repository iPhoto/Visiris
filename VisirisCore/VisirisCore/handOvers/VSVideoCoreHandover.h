//
//  VSVideoCoreHandover.h
//  VisirisCore
//
//  Created by Edwin Guggenbichler on 9/24/12.
//
//

#import "VSFrameCoreHandover.h"

@interface VSVideoCoreHandover : VSFrameCoreHandover

@property (assign) BOOL     hasAudio;

-(id) initWithFrame:(VSImage *) inFrame andAttributes:(NSDictionary *) theAttributes forTimestamp:(double)theTimestamp forId:(NSInteger) theId withAudio:(BOOL)audio;

@end
