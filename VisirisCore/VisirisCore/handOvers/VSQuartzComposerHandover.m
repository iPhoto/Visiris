//
//  VSQuartzComposerHandover.m
//  VisirisCore
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQuartzComposerHandover.h"

@implementation VSQuartzComposerHandover

@synthesize filePath = _filePath;
@synthesize textureID = _textureID;

-(id) initWithAttributes:(NSDictionary *)theAttributes forTimestamp:(double)theTimestamp andFilePath:(NSString *)theFilePath forId:(NSInteger)theId forTextureID:(GLuint)aTextureID{
    if(self = [super initWithAttributes:theAttributes forTimestamp:theTimestamp forId:theId]){
        self.filePath = theFilePath;
        self.textureID = aTextureID;
    }
    return self;
}

@end
