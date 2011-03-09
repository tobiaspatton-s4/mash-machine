//
//  MashStepCell.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MashStepCell.h"
#import "Constants.h"
#import "MashCalculations.h"

enum {
	kTagTextLabel = 1,
	kTagTimeAndTempLabel,
	kTagDetailsLabel
};

const double kPoundsPerQuartWater = 2.086351011735304;
const double kMashHeatCapacity = 0.4;

@interface MashStepCell ()

- (void) updateUserInterface;
- (NSString *) textForDecoctionStep;
- (NSString *) textForInfusionStep;
- (NSString *) textForHeatingStep;
- (void) mashConditionsPriorToStepAtIndex:(int) index totalWaterVolume:(NSNumber **) outVolume mashTemp:(NSNumber **) outTemp;

@end

@implementation MashStepCell

@synthesize mashStep;
@synthesize mashInfo;

- (void) mashConditionsPriorToStepAtIndex:(int) index totalWaterVolume:(NSNumber **) outVolume mashTemp:(NSNumber **) outTemp {
	// first infusion step has water volume set explicitly
	NSManagedObject *step = [[mashInfo mashSteps] objectAtIndex:0];
	float waterVolume = [[mashInfo waterVolume] floatValue];
	NSNumber *prevStepTemp = [step valueForKey:@"restStopTemp"];

	for (int i = 1; i < index; i++) {
		// subsequent infusion steps have water volume calculated
		step = [[mashInfo mashSteps] objectAtIndex:i];
		prevStepTemp = [step valueForKey:@"restStopTemp"];

		if ([(NSNumber *)[step valueForKey:@"type"] intValue] != kMashStepTypeInfusion) {
			// no water is added during decoction or direct heating
			continue;
		}

		float stepWaterMass = infusionWaterMass(kMashHeatCapacity,
		                                        [[mashInfo gristWeight] floatValue],
		                                        waterVolume * kPoundsPerQuartWater,
		                                        [(NSNumber *)[step valueForKey:@"restStartTemp"] floatValue],
		                                        [prevStepTemp floatValue],
		                                        [(NSNumber *)[step valueForKey:@"infuseTemp"] floatValue]);

		waterVolume += stepWaterMass / kPoundsPerQuartWater;
	}
	*outVolume = [NSNumber numberWithFloat:waterVolume];
	*outTemp = prevStepTemp;
}

- (NSString *) textForDecoctionStep {
	NSNumber *totalVolume = nil;
	NSNumber *mashTemp = nil;
	int stepIdx = [[mashInfo mashSteps] indexOfObject:mashStep];
	if (stepIdx > 0) {
		[self mashConditionsPriorToStepAtIndex:stepIdx totalWaterVolume:&totalVolume mashTemp:&mashTemp];

		float decoctMass = decoctionMass(kMashHeatCapacity,
		                                 [[mashInfo gristWeight] floatValue],
		                                 [totalVolume floatValue] * kPoundsPerQuartWater,
		                                 [(NSNumber *)[mashStep valueForKey:@"restStartTemp"] floatValue],
		                                 [(NSNumber *)[mashStep valueForKey:@"decoctTemp"] floatValue],
		                                 [mashTemp floatValue]);

		NSNumber *stepTime = [mashStep valueForKey:@"stepTime"];
		//	NSNumber *decoctThickness = [mashStep valueForKey:@"decoctThickness"];
		NSNumber *decoctVolume = [NSNumber numberWithFloat:decoctMass / kPoundsPerQuartWater]; // [decoctThickness floatValue]];

		return [NSString stringWithFormat:@"Decoct %@ and boil for %@",
		        [mashInfo.volumeFormatter stringFromNumber:decoctVolume],
		        [mashInfo.timeFormatter stringFromNumber:stepTime]];
	}
	else {
		return @"First step must be infusion.";
	}
}

- (NSString *) textForInfusionStep {
	NSNumber *infuseVolume = [mashInfo waterVolume];
	NSNumber *infuseTemp = [mashStep valueForKey:@"infuseTemp"];
	int stepIdx = [[mashInfo mashSteps] indexOfObject:mashStep];

	if (stepIdx == 0) {
		// initial strike
		float tw = strikeWaterTemperature([[mashInfo waterVolume] floatValue] * kPoundsPerQuartWater,
		                                  [(NSNumber *)[mashStep valueForKey:@"restStartTemp"] floatValue],
		                                  kMashHeatCapacity,
		                                  [[mashInfo gristWeight] floatValue],
		                                  [[mashInfo gristTemp] floatValue]);
		infuseTemp = [NSNumber numberWithFloat:tw];
	}
	else {
		NSNumber *totalVolume = nil;
		NSNumber *mashTemp = nil;
		[self mashConditionsPriorToStepAtIndex:stepIdx totalWaterVolume:&totalVolume mashTemp:&mashTemp];

		float waterMass = infusionWaterMass(kMashHeatCapacity,
		                                    [[mashInfo gristWeight] floatValue],
		                                    [totalVolume floatValue] * kPoundsPerQuartWater,
		                                    [(NSNumber *)[mashStep valueForKey:@"restStartTemp"] floatValue],
		                                    [mashTemp floatValue],
		                                    [(NSNumber *)[mashStep valueForKey:@"infuseTemp"] floatValue]);
		infuseVolume = [NSNumber numberWithFloat:waterMass / kPoundsPerQuartWater];
	}

	return [NSString stringWithFormat:@"Add %@ of water at %@",
	        [mashInfo.volumeFormatter stringFromNumber:infuseVolume],
	        [mashInfo.tempFormatter stringFromNumber:infuseTemp]];
}

- (NSString *) textForHeatingStep {
	return [NSString stringWithFormat:@"Heat to %@",
	        [mashInfo.tempFormatter stringFromNumber:[mashStep valueForKey:@"restStartTemp"]]];
}

- (void) setMashStep:(NSManagedObject *) value {
	[mashStep autorelease];
	mashStep = [value retain];
	[self updateUserInterface];
}

- (id)initWithStyle:(UITableViewCellStyle) style reuseIdentifier:(NSString *) reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code.
	}
	return self;
}

- (void)setSelected:(BOOL) selected animated:(BOOL) animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state.
}

- (UILabel *) textLabel {
	return (UILabel *)[self viewWithTag:kTagTextLabel];
}

- (UILabel *) detailTextLabel {
	return (UILabel *)[self viewWithTag:kTagDetailsLabel];
}

- (UILabel *) timeAndTempLabel {
	return (UILabel *)[self viewWithTag:kTagTimeAndTempLabel];
}

- (void)dealloc {
	[mashStep release];
	[super dealloc];
}

- (void) updateUserInterface {
	if (mashStep == nil) {
		self.textLabel.text = self.detailTextLabel.text = self.timeAndTempLabel.text = @"";
		return;
	}

	self.textLabel.text = [mashStep valueForKey:@"name"];

	NSNumber *restTemp = [mashStep valueForKey:@"restStartTemp"];
	NSNumber *restTime = [mashStep valueForKey:@"restTime"];

	self.timeAndTempLabel.text = [NSString stringWithFormat:@"%@ F for %@ minutes", restTemp, restTime];

	int stepType = [(NSNumber *)[mashStep valueForKey:@"type"] intValue];
	switch (stepType) {
	case kMashStepTypeDecoction:
		self.detailTextLabel.text = [self textForDecoctionStep];
		break;

	case kMashStepTypeInfusion:
		self.detailTextLabel.text = [self textForInfusionStep];
		break;

	case kMashStepTypeDirectHeat:
		self.detailTextLabel.text = [self textForHeatingStep];
		break;

	default:
		break;
	}
}

@end