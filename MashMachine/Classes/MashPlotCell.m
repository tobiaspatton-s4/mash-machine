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

	// Create graph from theme
	
	CPXYGraph *graph = [[[CPXYGraph alloc] initWithFrame:CGRectZero] autorelease];
	CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
	[graph applyTheme:theme];
	hostView.hostedGraph = graph;
	
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.cornerRadius = 0.0f;
    graph.plotAreaFrame.paddingLeft = 30.0;
	graph.plotAreaFrame.paddingBottom = 20.0;
	graph.plotAreaFrame.paddingTop = 20.0;
	graph.plotAreaFrame.paddingRight = 20.0;	
	
	graph.plotAreaFrame.plotArea.position = CGPointMake(50.0, 50.0);

	// Setup plot space
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = NO;
	
	float gristTemp = [mashInfo.gristTemp floatValue];
	
	plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) 
												   length:CPDecimalFromFloat([lastPlotTime floatValue])];
																			 
	plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(gristTemp) 
												   length:CPDecimalFromFloat(220.0 - gristTemp)];

	NSNumberFormatter *labelFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[labelFormatter setMaximumFractionDigits:0];

	CPLineStyle *majorTickStyle = [CPLineStyle lineStyle];
	majorTickStyle.lineWidth = 1;
	majorTickStyle.lineColor = [CPColor lightGrayColor];
	
	CPLineStyle *minorTickStyle = [CPLineStyle lineStyle];
	minorTickStyle.lineWidth = 1;
	minorTickStyle.lineColor = [CPColor lightGrayColor];

	/*
	CPPlotRange *xAxisPlotRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat([lastPlotTime floatValue])];
	CPPlotRange *yAxisPlotRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(gristTemp) 
															  length:CPDecimalFromFloat(220 - gristTemp)];
*/
	// Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
	CPXYAxis *x = axisSet.xAxis;
	//x.visibleRange = xAxisPlotRange;
	//x.gridLinesRange = yAxisPlotRange;
	x.majorGridLineStyle = majorTickStyle;
	x.minorGridLineStyle = minorTickStyle;
	x.orthogonalCoordinateDecimal = CPDecimalFromFloat(gristTemp);
	x.majorIntervalLength = CPDecimalFromString(@"20");
	x.minorTicksPerInterval = 3;
	x.labelFormatter = labelFormatter;
	x.majorTickLineStyle = majorTickStyle;
	x.minorTickLineStyle = minorTickStyle;

	CPXYAxis *y = axisSet.yAxis;
	//y.visibleRange = yAxisPlotRange;
	//y.gridLinesRange = xAxisPlotRange;
	y.majorGridLineStyle = majorTickStyle;
	y.minorGridLineStyle = minorTickStyle;
	y.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");
	y.majorIntervalLength = CPDecimalFromString(@"30");
	y.minorTicksPerInterval = 2;
	y.labelFormatter = labelFormatter;
	y.majorTickLineStyle = majorTickStyle;
	y.minorTickLineStyle = minorTickStyle;

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
	NSMutableArray *result = [NSMutableArray array];
	NSMutableArray *mainPlot = [NSMutableArray array];
	[result addObject:mainPlot];

	[mainPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
	                     [NSNumber numberWithFloat:0.0], @"time",
	                     mashInfo.gristTemp, @"temp",
	                     nil]];
	
	NSNumber *prevRestTemp = mashInfo.gristTemp;
	float time = 0.0;
	for (NSManagedObject *step in mashInfo.mashSteps) {
		NSMutableArray *stepPlot = [NSMutableArray array];
		[result addObject:stepPlot];

		NSNumber *startTemp = (NSNumber *)[step valueForKey:@"restStartTemp"];
		NSNumber *stopTemp = (NSNumber *)[step valueForKey:@"restStopTemp"];
		NSNumber *stepTime = (NSNumber *)[step valueForKey:@"stepTime"];
		NSNumber *restTime = (NSNumber *)[step valueForKey:@"restTime"];
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
				                            [(NSNumber *)[step valueForKey:@"restStartTemp"] floatValue],
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
			                     additionTemp, @"temp",
			                     nil]];
			break;

		case kMashStepTypeDecoction:
				additionTemp = (NSNumber *)[step valueForKey:@"decoctTemp"];
				boilTime = (NSNumber *)[step valueForKey:@"boilTime"];							
				
				[stepPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithFloat:time - [stepTime floatValue]], @"time",
									 prevRestTemp, @"temp",
									 nil]];
				
				[stepPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithFloat:time - [boilTime floatValue]], @"time",
									 additionTemp, @"temp",
									 nil]];
				
				[stepPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithFloat:time], @"time",
									 additionTemp, @"temp",
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
		                     startTemp, @"temp",
		                     nil]];

		[stepPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		                     [NSNumber numberWithFloat:time], @"time",
		                     startTemp, @"temp",
		                     nil]];

		time = time +[restTime floatValue] - [stepTime floatValue];
		[mainPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		                     [NSNumber numberWithFloat:time], @"time",
		                     stopTemp, @"temp",
		                     nil]];
		
		prevRestTemp = startTemp; // Todo: get actual spot on possible sloped line
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