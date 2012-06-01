//
//  VSDocument.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 31.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VSDocument : NSDocument

-(BOOL) addFileToProject:(NSString*) fileName;

@end
