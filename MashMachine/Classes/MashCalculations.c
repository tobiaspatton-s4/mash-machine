/*
 *  MashCalculations.c
 *  MashMachine
 *
 *  Created by Tobias Patton on 11-03-02.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "MashCalculations.h"

float strikeWaterTemperature(float ma,float tf,	float hcm, float mm, float tm) {
	return (ma * tf-(hcm*mm)*(tm-tf))/ma;
}