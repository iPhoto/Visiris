//
//  VSFileKind.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 13.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef VisirisUI_VSFileKind_h
#define VisirisUI_VSFileKind_h

/**
 * Defines the kinds of files Visirs suports.
 *
 * According to its kind the VSTimelineObjectFactory creates the corresponding VSTimelineObjectSource. The kind is also important for deciding how to render its content
 */
typedef enum {
    VSFileKindVideo = 1,
    VSFileKindImage = 2,
    VSFileKindAudio = 3,
    VSFileKindQuartzComposerPatch = 4
} VSFileKind;

#endif
