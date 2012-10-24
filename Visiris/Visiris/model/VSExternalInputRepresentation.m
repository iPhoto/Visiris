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
@synthesize value = _value;

-(id) initWithExternalInput:(VSExternalInput*) externalInput{
    if(self = [self init]){
        _externalInput = externalInput;
        self.name = @"Name";
        self.range = externalInput.range;
        self.selected = NO;
        _value = self.externalInput.value;
    }
    
    return self;
}

-(void) reset{
    self.name = @"Name";
    self.range = self.externalInput.range;
    self.selected = NO;
    _value = self.externalInput.value;
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
    return _value;
}

-(NSString*) parameterDataType{
    return self.externalInput.parameterTypeName;
}

-(NSString*) deviceType{
    return self.externalInput.deviceTypeName;
}

-(BOOL) hasRange{
    return self.externalInput.hasRange;
}

@end
