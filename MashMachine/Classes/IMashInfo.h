//
//  IMashInfo.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MashStep;

@protocol IMashInfo

- (NSNumber *) gristWeight;
- (NSNumber *) waterGristRatio;
- (NSNumber *) waterVolume;
- (NSNumber *) mashTunThermalMass;
- (NSNumber *) gristTemp;
- (NSArray *) mashSteps;
- (void) addStep: (MashStep *) step;

@end
