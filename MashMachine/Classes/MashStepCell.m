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

@interface MashStepCell ()

- (void) updateUserInterface;
- (NSString *) textForDecoctionStep;
- (NSString *) textForInfusionStep;
- (NSString *) textForHeatingStep;

@end

@implementation MashStepCell

@synthesize mashStep;

- (NSString *) textForDecoctionStep {
	NSNumber *decoctVolume = [NSNumber numberWithFloat:6.0]; // todo: calculate
	NSNumber *stepTime = [mashStep valueForKey:@"stepTime"];
	return [NSString stringWithFormat: @"Decoct %@ qt and boil for %@ minutes", decoctVolume, stepTime];
}

- (NSString *) textForInfusionStep {
	NSNumber *infuseVolume = [NSNumber numberWithFloat:6.0]; // todo: calculate
	NSNumber *infuseTemp = [mashStep valueForKey:@"infuseTemp"]; // todo: calculate if null (first step)
	
	if (infuseTemp == nil || [infuseTemp floatValue] == 0) {
		float tw = strikeWaterTemperature(20 * kPoundsPerQuartWater, 150, 0.4, 10, 60);
		infuseTemp = [NSNumber numberWithFloat:tw];
	}
	return [NSString stringWithFormat: @"Add %@ qt of water at %@ F.", infuseVolume, infuseTemp];	
}

- (NSString *) textForHeatingStep {
	return @"Apply heat";
	
}

- (void) setMashStep:(NSManagedObject *) value {
	[mashStep autorelease];
	mashStep = [value retain];
	[self updateUserInterface];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
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
	
	self.timeAndTempLabel.text = [NSString stringWithFormat:@"%@ F. for %@ minutes", restTemp, restTime];	
	
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
