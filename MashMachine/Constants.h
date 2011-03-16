/*
 *  Constants.h
 *  MashMachine
 *
 *  Created by Tobias Patton on 11-02-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

extern const double kPoundsPerQuartWater;
extern const double kMashHeatCapacity;

enum {
	kMashStepTypeDirectHeat = 0,
	kMashStepTypeInfusion = 1,
	kMashStepTypeDecoction = 2
};