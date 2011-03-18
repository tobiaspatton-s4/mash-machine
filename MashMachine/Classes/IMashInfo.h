//
//  IMashInfo.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-03.
//  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MashStep;
@class UnitNumberFormater;

@protocol IMashInfo

- (NSNumber *) gristWeight;
- (NSNumber *) waterGristRatio;
- (NSNumber *) waterVolume;
- (NSNumber *) mashTunThermalMass;
- (NSNumber *) gristTemp;
- (NSArray *) mashSteps;

- (UnitNumberFormater *) weightFormatter;
- (UnitNumberFormater *) volumeFormatter;
- (UnitNumberFormater *) densityFormatter;
- (UnitNumberFormater *) tempFormatter;
- (UnitNumberFormater *) timeFormatter;

@end
