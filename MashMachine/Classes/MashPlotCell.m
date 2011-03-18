//
//  MashPlotCell.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-14.
//  Copyright 2011 Blue Cedar Creative. All rights reserved.
//

#import "MashPlotCell.h"
#import "Constants.h"
#import "MashCalculations.h"
#import "UnitConverter.h"
#import "Entities.h"
#import <CoreData/CoreData.h>

@interface MashPlotCell ()

- (void) configureUI;
- (NSArray *) plotDataFromMashInfo;
@end


@implementation MashPlotCell

@synthesize mashInfo;
@synthesize hostView;
@synthesize allPlotData;

enum {
	kTagPlaceholderView = 1
};

- (void) setMashInfo:(id <IMashInfo>) value {
	mashInfo = value;
	[self configureUI];
}

- (void) awakeFromNib {
	// replace the placeholder view with a GPGraphHostingView
	UIView *view = [self viewWithTag:kTagPlaceholderView];
	CPGraphHostingView *host = [[CPGraphHostingView alloc] initWithFrame:[view frame]];
	[host setAutoresizingMask:[view autoresizingMask]];
	UIView *container = [view superview];
	[view removeFromSuperview];
	[container addSubview:host];

	self.hostView = host;
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

- (void)dealloc {
	[hostView release];
	[allPlotData release];
	[super dealloc];
}

- (void) configureUI {
	self.allPlotData = [self plotDataFromMashInfo];
	NSArray *mainPlotData = [self.allPlotData objectAtIndex:0];
	NSNumber *lastPlotTime = [(NSDictionary *)[mainPlotData lastObject] objectForKey:@"time"];
	if ([lastPlotTime floatValue] == 0.0) {
		lastPlotTime = [NSNumber numberWithFloat:60.0];
	}

	// Create graph from theme

	CPXYGraph *graph = [[[CPXYGraph alloc] initWithFrame:CGRectZero] autorelease];
	CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
	[graph applyTheme:theme];
	hostView.hostedGraph = graph;
	
	graph.paddingLeft = 0.0;
	graph.paddingBottom = 0.0;
	graph.paddingTop = 0.0;
	graph.paddingRight = 0.0;

	graph.plotAreaFrame.borderLineStyle = nil;
	graph.plotAreaFrame.cornerRadius = .0f;
	graph.plotAreaFrame.paddingLeft = 50.0;
	graph.plotAreaFrame.paddingBottom = 40.0;
	graph.plotAreaFrame.paddingTop = 10.0;
	graph.plotAreaFrame.paddingRight = 10.0;

	// Setup plot space
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = NO;
	
	EConversionUnit displayUnit = [(NSNumber *)[[NSUserDefaults standardUserDefaults] 
												valueForKey:@"prefUnitsTemperature"] intValue];
	id<IConverter> tempConverter = [Converter converterFromCannonicalUnit:kUnitFahrenheit toDisplayUnit:displayUnit];

	float gristTemp = [[tempConverter convertToDisplay:mashInfo.gristTemp] floatValue];
	float maxTemp = (displayUnit == kUnitFahrenheit) ? 220 : 110;

	plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0)
	                                               length:CPDecimalFromFloat([lastPlotTime floatValue])];

	plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(gristTemp)
	                                               length:CPDecimalFromFloat(maxTemp - gristTemp)];

	NSNumberFormatter *labelFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[labelFormatter setMaximumFractionDigits:0];

	CPLineStyle *majorTickStyle = [CPLineStyle lineStyle];
	majorTickStyle.lineWidth = 1;
	majorTickStyle.lineColor = [CPColor lightGrayColor];

	CPLineStyle *minorTickStyle = [CPLineStyle lineStyle];
	minorTickStyle.lineWidth = 1;
	minorTickStyle.lineColor = [CPColor lightGrayColor];

	// Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
	CPXYAxis *x = axisSet.xAxis;
	x.majorGridLineStyle = majorTickStyle;
	x.minorGridLineStyle = minorTickStyle;
	x.orthogonalCoordinateDecimal = CPDecimalFromFloat(gristTemp);
	if ([lastPlotTime floatValue] > 120.0) {
		x.majorIntervalLength = CPDecimalFromString(@"40");
	} else {		
		x.majorIntervalLength = CPDecimalFromString(@"20");
	}
	x.minorTicksPerInterval = 3;
	x.labelFormatter = labelFormatter;
	x.majorTickLineStyle = majorTickStyle;
	x.minorTickLineStyle = minorTickStyle;
	x.title = @"Minutes";
	x.titleOffset = 22.0;

	CPXYAxis *y = axisSet.yAxis;
	y.majorGridLineStyle = majorTickStyle;
	y.minorGridLineStyle = minorTickStyle;
	y.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");
	y.labelFormatter = labelFormatter;
	y.majorTickLineStyle = majorTickStyle;
	y.minorTickLineStyle = minorTickStyle;	
	y.titleOffset = 30.0;
	
	if (displayUnit == kUnitCelsius) {
		y.majorIntervalLength = CPDecimalFromString(@"20");	
		y.minorTicksPerInterval = 1;		
		y.title = @"Deg. C";
	}
	else {
		y.majorIntervalLength = CPDecimalFromString(@"30");		
		plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(gristTemp)
													   length:CPDecimalFromFloat(220.0 - gristTemp)];
		y.minorTicksPerInterval = 2;		
		y.title = @"Deg. F";
	}

	// Create the temp profile plot
	CPScatterPlot *mainPlot = [[[CPScatterPlot alloc] init] autorelease];
	mainPlot.identifier = [NSNumber numberWithInt:0];

	CPLineStyle *lineStyle = [CPLineStyle lineStyle];
	lineStyle.lineWidth = 2.0f;
	lineStyle.lineColor = [CPColor blackColor];
	mainPlot.dataLineStyle = lineStyle;
	mainPlot.dataSource = self;
	[graph addPlot:mainPlot];

	//Create one plot for each addition

	CPLineStyle *additionLineStyle = [CPLineStyle lineStyle];
	additionLineStyle.dashPattern = [NSArray arrayWithObjects:
	                                 [NSNumber numberWithFloat:5.0f], [NSNumber numberWithFloat:5.0f], nil];
	additionLineStyle.lineWidth = 1.0f;
	additionLineStyle.lineColor = [CPColor blackColor];

	for (int i = 0; i < [mashInfo.mashSteps count]; i++) {
		CPScatterPlot *stepPlot = [[[CPScatterPlot alloc] init] autorelease];
		stepPlot.identifier = [NSNumber numberWithInt:i + 1];
		stepPlot.dataLineStyle = additionLineStyle;
		stepPlot.dataSource = self;

		[graph addPlot:stepPlot];
	}
}

- (NSArray *) plotDataFromMashInfo {	
	EConversionUnit displayUnit = [(NSNumber *)[[NSUserDefaults standardUserDefaults] 
												valueForKey:@"prefUnitsTemperature"] intValue];
	id<IConverter> tempConverter = [Converter converterFromCannonicalUnit:kUnitFahrenheit toDisplayUnit:displayUnit];
	
	NSMutableArray *result = [NSMutableArray array];
	NSMutableArray *mainPlot = [NSMutableArray array];
	[result addObject:mainPlot];

	[mainPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
	                     [NSNumber numberWithFloat:0.0], @"time",
	                     [tempConverter convertToDisplay:mashInfo.gristTemp], @"temp",
	                     nil]];

	MashStep *previousStep;
	float previousTime = 0.0;

	float time = 0.0;
	for (MashStep *step in mashInfo.mashSteps) {
		NSMutableArray *stepPlot = [NSMutableArray array];
		[result addObject:stepPlot];
		
		NSNumber *stepTime = [step.stepTime copy];;
		int stepType = [(NSNumber *)[step valueForKey:@"type"] intValue];
		int stepIdx = [[mashInfo mashSteps] indexOfObject:step];

		NSNumber *additionTemp;
		NSNumber *boilTime;

		float tw;

		switch (stepType) {
		case kMashStepTypeInfusion:
			if (stepIdx == 0) {
				// initial strike
				tw = strikeWaterTemperature([[mashInfo waterVolume] floatValue] * kPoundsPerQuartWater,
				                            [step.restStartTemp floatValue],
				                            kMashHeatCapacity,
				                            [[mashInfo gristWeight] floatValue],
				                            [[mashInfo gristTemp] floatValue]);
				additionTemp = [NSNumber numberWithFloat:tw];
			}
			else {
				additionTemp = (NSNumber *)[step valueForKey:@"infuseTemp"];
			}

			[stepPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			                     [NSNumber numberWithFloat:time], @"time",
			                     [tempConverter convertToDisplay:additionTemp], @"temp",
			                     nil]];
			break;

		case kMashStepTypeDecoction:
			additionTemp = (NSNumber *)[step valueForKey:@"decoctTemp"];
			boilTime = (NSNumber *)[step valueForKey:@"boilTime"];

			// end temp may differ for start temp. to place the "pull decoction" data
			// point at the right point (ie. on the line), we must calculate the line's
			// slope and adjust to y-position accordingly.

			float lineSlope = ([previousStep.restStopTemp floatValue] -
			                   [previousStep.restStartTemp floatValue]) /
			                  [previousStep.restTime floatValue];

			NSNumber *pullTime = [NSNumber numberWithFloat:time - [step.stepTime floatValue]];

			float actualTemp = [previousStep.restStartTemp floatValue] +
			                   lineSlope * ([pullTime floatValue] - previousTime);

			[stepPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			                     pullTime, @"time",
			                     [tempConverter convertToDisplay:[NSNumber numberWithFloat:actualTemp]], @"temp",
			                     nil]];

			[stepPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			                     [NSNumber numberWithFloat:time - [boilTime floatValue]], @"time",
			                     [tempConverter convertToDisplay:additionTemp], @"temp",
			                     nil]];

			[stepPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			                     [NSNumber numberWithFloat:time], @"time",
			                     [tempConverter convertToDisplay:additionTemp], @"temp",
			                     nil]];

			// stepTime now becomes rise time, which is fixed a 5.0 minutes for decoction steps
			stepTime = [NSNumber numberWithFloat:5.0];
			break;

		default:
			break;
		}

		time += [stepTime floatValue];
		[mainPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		                     [NSNumber numberWithFloat:time], @"time",
		                     [tempConverter convertToDisplay:step.restStartTemp], @"temp",
		                     nil]];

		previousTime = time;
		[stepPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		                     [NSNumber numberWithFloat:time], @"time",
		                     [tempConverter convertToDisplay:step.restStartTemp], @"temp",
		                     nil]];

		time = time +[step.restTime floatValue] - [stepTime floatValue];
		[mainPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		                     [NSNumber numberWithFloat:time], @"time",
		                     [tempConverter convertToDisplay:step.restStopTemp], @"temp",
		                     nil]];

		previousStep = step;
	}

	return result;
}

#pragma mark -
#pragma mark CPPlotDataSource methods

- (NSUInteger)numberOfRecordsForPlot:(CPPlot *) plot {
	int plotDataIdx = [(NSNumber *)plot.identifier intValue];
	NSArray *plotData = [self.allPlotData objectAtIndex:plotDataIdx];
	return [plotData count];
}

- (NSNumber *)numberForPlot:(CPPlot *) plot field:(NSUInteger) fieldEnum recordIndex:(NSUInteger) index {
	int plotDataIdx = [(NSNumber *)plot.identifier intValue];
	NSArray *plotData = [self.allPlotData objectAtIndex:plotDataIdx];
	NSDictionary *d = [plotData objectAtIndex:index];
	if (fieldEnum == CPScatterPlotFieldX) {
		return [d objectForKey:@"time"];
	}
	return [d objectForKey:@"temp"];
}

@end