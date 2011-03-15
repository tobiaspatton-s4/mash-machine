//
//  MashPlotCell.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-14.
//  Copyright 2011 Blue Cedar Creative. All rights reserved.
//

#import "MashPlotCell.h"
#import <CoreData/CoreData.h>

@interface MashPlotCell ()

- (void) configureUI;
- (NSArray *) plotDataFromMashInfo;

@end


@implementation MashPlotCell

@synthesize mashInfo;
@synthesize hostView;
@synthesize mainPlotData;

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
	[mainPlotData release];
	[super dealloc];
}

- (void) configureUI {
	// Create graph from theme
	CPXYGraph *graph = [[[CPXYGraph alloc] initWithFrame:CGRectZero] autorelease];
	CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
	[graph applyTheme:theme];
	hostView.hostedGraph = graph;

	graph.paddingLeft = 10.0;
	graph.paddingTop = 10.0;
	graph.paddingRight = 10.0;
	graph.paddingBottom = 10.0;
	
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
	
	// to do: get x-range from mash steps
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-10.0) length:CPDecimalFromFloat(140.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(240.0)];
	
	NSNumberFormatter *labelFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[labelFormatter setMaximumFractionDigits:0];
	
	CPLineStyle *majorTickStyle = [CPLineStyle lineStyle];
	majorTickStyle.lineWidth = 1;
	
	CPPlotRange *xAxisPlotRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(120.0)];
	CPPlotRange *yAxisPlotRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(30.0) length:CPDecimalFromFloat(190.0)];
	
	// Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
	x.visibleRange = xAxisPlotRange;
	x.gridLinesRange = yAxisPlotRange;
	x.majorGridLineStyle = majorTickStyle;
    x.orthogonalCoordinateDecimal = CPDecimalFromString(@"30");
    x.majorIntervalLength = CPDecimalFromString(@"20");
    x.minorTicksPerInterval = 3;
	x.labelFormatter = labelFormatter;
	x.majorTickLineStyle = majorTickStyle;
	
    CPXYAxis *y = axisSet.yAxis;
	y.visibleRange = yAxisPlotRange;
	y.gridLinesRange = xAxisPlotRange;
	y.majorGridLineStyle = majorTickStyle;
    y.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");
    y.majorIntervalLength = CPDecimalFromString(@"30");
    y.minorTicksPerInterval = 2;
	y.labelFormatter = labelFormatter;
	y.majorTickLineStyle = majorTickStyle;
	
    // Create the temp profile plot
	CPScatterPlot *mainPlot = [[[CPScatterPlot alloc] init] autorelease];
    mainPlot.identifier = @"Main Plot";
    
    CPLineStyle *lineStyle = [CPLineStyle lineStyle];
	lineStyle.lineWidth = 1.0f;
    lineStyle.lineColor = [CPColor blackColor];
    mainPlot.dataLineStyle = lineStyle;    
    mainPlot.dataSource = self;
	[graph addPlot:mainPlot];
	
	self.mainPlotData = [self plotDataFromMashInfo];
}

- (NSArray *) plotDataFromMashInfo {
	NSMutableArray *result = [NSMutableArray array];
	
	[result addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					   [NSNumber numberWithFloat:0.0], @"time",
					   mashInfo.gristTemp, @"temp", 
					   nil]];
	
	float time = 0.0;
	for (NSManagedObject *step in mashInfo.mashSteps) {
		NSNumber *startTemp = (NSNumber *)[step valueForKey:@"restStartTemp"];
		NSNumber *stopTemp = (NSNumber *)[step valueForKey:@"restStopTemp"];
		NSNumber *stepTime = (NSNumber *)[step valueForKey:@"stepTime"];
		NSNumber *restTime = (NSNumber *)[step valueForKey:@"restTime"];		
		
		time += [stepTime floatValue];	
		[result addObject:[NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithFloat:time], @"time",
						   startTemp, @"temp", 
						   nil]];		
		
		time += [restTime floatValue];	
		[result addObject:[NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithFloat:time], @"time",
						   stopTemp, @"temp", 
						   nil]];
		
	}
	
	return result;
}

#pragma mark -
#pragma mark CPPlotDataSource methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
	return [mainPlotData count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	NSDictionary *d = [mainPlotData objectAtIndex:index];
	if (fieldEnum == CPScatterPlotFieldX) {
		return [d objectForKey:@"time"];
	}
	return [d objectForKey:@"temp"];
	
}
@end