//
//  VSExternalInputRepresentation.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 22.10.12.
//
//

#import "VSExternalInputRepresentation.h"


@interface VSExternalInputRepresentation()



@end

@implementation VSExternalInputRepresentation

@synthesize range                   = _range;

-(id) initWithExternalInput:(VSExternalInput*) externalInput{
    if(self = [self init]){
        _externalInput = externalInput;
        self.name = @"Name";
        self.range = externalInput.range;
        self.selected = NO;
    }
    
    return self;
}


-(VSRange) range{
    return _range;
}

-(void) setRange:(VSRange)range{
    _range = range;
}

-(NSString*) identifier{
    return self.externalInput.identifier;
}

-(id) value{
    return self.externalInput.value;
}

-(NSString*) parameterDataType{
    return self.externalInput.parameterTypeName;
}

-(NSString*) deviceType{
    return self.externalInput.deviceTypeName;
}


@end
