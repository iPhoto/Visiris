//
//  VSVideoCoreHandover.m
//  VisirisCore
//
//  Created by Edwin Guggenbichler on 9/24/12.
//
//

#import "VSVideoCoreHandover.h"

@implementation VSVideoCoreHandover
@synthesize hasAudio =      _hasAudio;

-(id) initWithFrame:(VSImage *) inFrame andAttributes:(NSDictionary *) theAttributes forTimestamp:(double)theTimestamp forId:(NSInteger) theId withAudio:(BOOL)audio{
    
    if (self = [super initWithFrame:inFrame andAttributes:theAttributes forTimestamp:theTimestamp forId:theId]) {
        self.hasAudio = audio;
    }
    return self;
}

@end
