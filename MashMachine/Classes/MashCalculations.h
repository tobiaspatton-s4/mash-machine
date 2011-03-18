/*
 *  MashCalculations.h
 *  MashMachine
 *
 *  Created by Tobias Patton on 11-03-02.
 *  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
 *
 */

double strikeWaterTemperature(double ma,	//mass of initial strike water
                             double tf,	//final temperature desired
                             double hcm, //heat capacity of malt
                             double mm,	//mass of malt
                             double tm); //temperature of malt

double infusionWaterMass(double hcm,		//heat capacity of malt
						double mm,		//mass of malt
						double mw,		//mass of water already in malt
						double tf,		//final temperature desired
						double tmash,	//current temperature of the mash
						double tw);		//temperature of infusion water

double decoctionMass(double hcm,		//heat capacity of malt
					double mm,		//mass of malt
					double mw,		//mass of water already in mash
					double tf,		//final temperature desired
					double td,		//temperature of decoction when added back to mash
					double tmash);	//current temparature of the mash