//
//  VSViewUtils.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 02.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSViewUtils : NSObject

static NSComparisonResult bringViewInContextToFront( NSView * view1, NSView * view2, void * context );

@end
