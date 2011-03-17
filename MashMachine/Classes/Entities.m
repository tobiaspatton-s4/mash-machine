//
//  Entities.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-17.
//  Copyright 2011 Blue Cedar Creative. All rights reserved.
//

#import "Entities.h"

@implementation MashProfile

@dynamic builtIn;
@dynamic creationDate;
@dynamic modificationDate;
@dynamic name;
@dynamic steps;

@end

@implementation MashStep

@dynamic boilTime;
@dynamic decoctTemp;
@dynamic decoctThickness;
@dynamic infuseTemp;
@dynamic name;
@dynamic restStartTemp;
@dynamic restStopTemp;
@dynamic restTime;
@dynamic stepOrder;
@dynamic stepTime;
@dynamic type;
@dynamic profile;

@end