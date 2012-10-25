//
//  VSExternalInputRepresentation.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 22.10.12.
//
//

#import "VSExternalInput.h"

#import "VSCoreServices.h"

@interface VSExternalInputRepresentation: NSObject


-(id) initWithExternalInput:(VSExternalInput*) externalInput;

@property (strong) NSString *name;
@property (assign) VSRange range;
@property (assign) BOOL selected;
@property (strong, readonly) VSExternalInput *externalInput;
@property (strong, readonly) id value;

-(NSString*) identifier;


-(NSString*) parameterDataType;

-(NSString*) deviceType;

-(void) reset;


-(BOOL) hasRange;

@end
