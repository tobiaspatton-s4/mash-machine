/*
 *  MashCalculations.c
 *  MashMachine
 *
 *  Created by Tobias Patton on 11-03-02.
 *  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
 *
 */

#include "MashCalculations.h"

double strikeWaterTemperature(double ma, double mttm, double tf,	double hcm, double mm, double tm) {
	return (ma * tf-(hcm*mm+mttm)*(tm-tf))/ma;
}

double infusionWaterMass(double hcm, double mttm, double mm, double mw, double tf, double tmash, double tw) {
	return (hcm*mm+mw+mttm)*(tf-tmash)/(tw-tf);
}

double decoctionMass(double hcm, double mttm, double mm, double mw, double tf, double td, double tmash) {
	return (hcm*mm+mw+mttm)/(1+((tf-td)/(tmash-tf)));
}