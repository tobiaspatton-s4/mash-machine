//
//  DetailViewController.m
//  MashMachine
//
//  Created by Tobias Patton on 11-02-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "TableCellFactory.h"
#import "ViewUtils.h"
#import "MashStepCell.h"
#import "EditStepViewController.h"
#import "EditableTextAndUnitsCell.h"
#import "MashMachineAppDelegate.h"
#import "Constants.h"
#import "UnitConverter.h"
#import "MashPlotCell.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
- (UITableViewCell *) getDetailsCellForRow:(int) row;
- (UITableViewCell *) getStepCellForRow:(int) row;
- (UITableViewCell *) getPlotCell;
- (void) editStep:(NSManagedObject *) step;
- (void) createUnitFormatters;
- (void) userDefaultsDidChange:(NSNotification *) aNotification;
@end

enum {
	kEditableTextCellTagGristWeight = 1000,
	kEditableTextCellTagWaterGristRatio,
	kEditableTextCellTagWaterVolume,
	kEditableTextCellTagMashTunThermalMass,
	kEditableTextCellTagGristTemp
};

enum {
	kSectionDetails,
	kSectionSteps,
	kSectionVisualization
};

enum {
	kRowGristWeight,
	kRowGristTemp,
	kRowWaterVolume,
	kRowWaterGristRatio,
	kRowMashTunThermalMass,
	kRowMashPlot
};

@implementation DetailViewController

@synthesize toolbar;
@synthesize popoverController;
@synthesize detailItem;
@synthesize rootViewController;
@synthesize mashSteps;
@synthesize mashStepsTable;
@synthesize gristWeight;
@synthesize waterGristRatio;
@synthesize waterVolume;
@synthesize mashTunThermalMass;
@synthesize volumeFormatter;
@synthesize gristTemp;
@synthesize toolbarTitle;
@synthesize editButton;
@synthesize weightFormatter;
@synthesize densityFormatter;
@synthesize tempFormatter;
@synthesize timeFormatter;


#pragma mark -
#pragma mark Properties

- (void) setWaterVolume:(NSNumber *) value {
	[waterVolume autorelease];
	waterVolume = [value retain];

	if (gristWeight != nil && waterVolume != nil) {
		[waterGristRatio release];
		waterGristRatio = [[NSNumber numberWithFloat:[waterVolume floatValue] / [gristWeight floatValue]] retain];
	}
}

- (void) setWaterGristRatio:(NSNumber *) value {
	[waterGristRatio autorelease];
	waterGristRatio = [value retain];

	if (gristWeight != nil && waterGristRatio != nil) {
		[waterVolume release];
		waterVolume = [[NSNumber numberWithFloat:[gristWeight floatValue] * [waterGristRatio floatValue]] retain];
	}
}

- (void) setGristWeight:(NSNumber *) value {
	[gristWeight autorelease];
	gristWeight = [value retain];

	if (gristWeight != nil && waterGristRatio != nil) {
		[waterVolume release];
		waterVolume = [[NSNumber numberWithFloat:[gristWeight floatValue] * [waterGristRatio floatValue]] retain];
	}
}

#pragma mark -
#pragma mark Managing the detail item

/*
   When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(NSManagedObject *) managedObject {
	if (detailItem != managedObject) {
		[detailItem release];
		detailItem = [managedObject retain];

		// Update the view.
		[self configureView];
	}

	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
}

- (void)configureView {
	// Update the user interface for the detail item.
	self.toolbarTitle.text = [detailItem valueForKey:@"name"];
	NSSet *steps = [detailItem valueForKey:@"steps"];
	NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"stepOrder" ascending:YES];
	NSArray *sortedSteps = [steps sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
	self.mashSteps = sortedSteps;
	[mashStepsTable reloadData];
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController:(UISplitViewController *) svc willHideViewController:(UIViewController *) aViewController withBarButtonItem:(UIBarButtonItem *) barButtonItem forPopoverController:(UIPopoverController *) pc {
	barButtonItem.title = @"Mash Profiles";
	NSMutableArray *items = [[toolbar items] mutableCopy];
	[items insertObject:barButtonItem atIndex:0];
	[toolbar setItems:items animated:YES];
	[items release];
	self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *) svc willShowViewController:(UIViewController *) aViewController invalidatingBarButtonItem:(UIBarButtonItem *) barButtonItem {
	NSMutableArray *items = [[toolbar items] mutableCopy];
	[items removeObjectAtIndex:0];
	[toolbar setItems:items animated:YES];
	[items release];
	self.popoverController = nil;
}

#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation duration:(NSTimeInterval) duration {
}

#pragma mark -
#pragma mark View lifecycle

- (void) userDefaultsDidChange:(NSNotification *) aNotification {
	[self createUnitFormatters];
	[mashStepsTable reloadData];
}

- (id) initWithCoder:(NSCoder *) aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.gristWeight = [NSNumber numberWithFloat:10.0];
		self.mashTunThermalMass = [NSNumber numberWithFloat:2.0];
		self.waterVolume = [NSNumber numberWithFloat:15.0];
		self.waterGristRatio = [NSNumber numberWithFloat:1.5];
		self.gristTemp = [NSNumber numberWithFloat:60];

		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(userDefaultsDidChange:)
		                                             name:NSUserDefaultsDidChangeNotification
		                                           object:nil];
	}
	return self;
}

- (void) createUnitFormatters {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

	UnitNumberFormater *vf = [[UnitNumberFormater alloc] initWithCannonicalUnit:kUnitQuart
	                                                             andDisplayUnit:[[prefs valueForKey:@"prefUnitsVolume"] intValue]];
	[vf setMaximumFractionDigits:1];
	[vf setMinimumFractionDigits:1];
	[vf setMinimumIntegerDigits:1];
	[vf setPaddingCharacter:@"0"];
	self.volumeFormatter = vf;
	[vf release];

	UnitNumberFormater *wf = [[UnitNumberFormater alloc] initWithCannonicalUnit:kUnitPound
	                                                             andDisplayUnit:[[prefs valueForKey:@"prefUnitsWeight"] intValue]];
	[wf setMaximumFractionDigits:1];
	[wf setMinimumFractionDigits:1];
	[wf setMinimumIntegerDigits:1];
	[wf setPaddingCharacter:@"0"];
	self.weightFormatter = wf;
	[wf release];

	UnitNumberFormater *df = [[UnitNumberFormater alloc] initWithCannonicalUnit:kUnitQuartsPerPound
	                                                             andDisplayUnit:[[prefs valueForKey:@"prefUnitsDensity"] intValue]];
	[df setMaximumFractionDigits:1];
	[df setMinimumFractionDigits:1];
	[df setMinimumIntegerDigits:1];
	[df setPaddingCharacter:@"0"];
	self.densityFormatter = df;
	[df release];

	UnitNumberFormater *tf = [[UnitNumberFormater alloc] initWithCannonicalUnit:kUnitFahrenheit
	                                                             andDisplayUnit:[[prefs valueForKey:@"prefUnitsTemperature"] intValue]];
	[tf setMaximumFractionDigits:1];
	[tf setMinimumFractionDigits:1];
	[tf setMinimumIntegerDigits:1];
	[tf setPaddingCharacter:@"0"];
	self.tempFormatter = tf;
	[tf release];

	UnitNumberFormater *timef = [[UnitNumberFormater alloc] initWithCannonicalUnit:kUnitMinute andDisplayUnit:kUnitMinute];
	[timef setMaximumFractionDigits:1];
	[timef setMinimumFractionDigits:1];
	[timef setMinimumIntegerDigits:1];
	[timef setPaddingCharacter:@"0"];
	self.timeFormatter = timef;
	[timef release];
}

- (void) viewDidLoad {
	[self createUnitFormatters];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.toolbar = nil;
	self.toolbarTitle = nil;
	self.popoverController = nil;
	self.mashStepsTable = nil;
	self.editButton = nil;
	self.weightFormatter = nil;
	self.densityFormatter = nil;
	self.tempFormatter = nil;
	self.timeFormatter = nil;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[popoverController release];
	[toolbar release];
	[toolbarTitle release];
	[detailItem release];
	[mashSteps release];
	[mashStepsTable release];
	[gristWeight release];
	[waterVolume release];
	[waterGristRatio release];
	[mashTunThermalMass release];
	[volumeFormatter release];
	[gristTemp release];
	[editButton release];
	[weightFormatter release];
	[densityFormatter release];
	[tempFormatter release];
	[timeFormatter release];

	[super dealloc];
}

- (void) editStep:(NSManagedObject *) step {
	EditStepViewController *controller = [[[EditStepViewController alloc] init] autorelease];
	controller.mashStep = step;
	controller.delegate = self;
	controller.mashInfo = self;

	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	navController.modalPresentationStyle = UIModalPresentationFormSheet;
	navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:navController animated:YES];
}

- (IBAction) addStepTouched:(id) sender {
	[self editStep:nil];
}

- (IBAction) editTouched:(id) sender {
	self.editButton = (UIButton *)sender;
	if (mashStepsTable.isEditing) {
		[mashStepsTable setEditing:NO animated:YES];
		[editButton setTitle:@"Edit" forState:UIControlStateNormal];
	}
	else {
		[mashStepsTable setEditing:YES animated:YES];
		[editButton setTitle:@"Done" forState:UIControlStateNormal];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (void)tableView:(UITableView *) tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath {
	NSManagedObjectContext *context = [(MashMachineAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	NSManagedObject *stepToDelete = [mashSteps objectAtIndex:indexPath.row];
	[context deleteObject:stepToDelete];
	[context save:nil];
	[self configureView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *) tableView {
	if (detailItem == nil) {
		return 0;
	}
	return 3;
}

- (NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	if (detailItem == nil) {
		return 0;
	}
	switch (section) {
	case kSectionDetails:
		return 4;
		break;

	case kSectionSteps:
		return [mashSteps count];
		break;

	case kSectionVisualization:
		return 1;
		break;

	default:
		return 0;
		break;
	}
}

- (NSString *)tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
	switch (section) {
	case kSectionDetails:
		return @"Details";
		break;

	case kSectionSteps:
		return @"Steps";
		break;

	case kSectionVisualization:
		return @"Plot";
		break;

	default:
		return @"";
		break;
	}
}

- (UITableViewCell *) getDetailsCellForRow:(int) row {
	NSString *const kDetailsTableCellId = @"EditableTextAndUnitsCell";
	EditableTextCell *cell = (EditableTextCell *)[mashStepsTable dequeueReusableCellWithIdentifier:kDetailsTableCellId];

	if (cell == nil) {
		cell = [TableCellFactory newEditableTextCell];
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	cell.textField.delegate = self;
	cell.textField.keyboardType = UIKeyboardTypeNumberPad;
	cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;

	switch (row) {
	case kRowGristWeight:
		cell.textLabel.text = @"Grist weight:";
		cell.textField.text = [weightFormatter stringFromNumber:gristWeight];
		cell.tag = kEditableTextCellTagGristWeight;
		break;

	case kRowWaterGristRatio:
		cell.textLabel.text = @"Water/grist ratio:";
		cell.textField.text = [densityFormatter stringFromNumber:waterGristRatio];
		cell.tag = kEditableTextCellTagWaterGristRatio;
		break;

	case kRowWaterVolume:
		cell.textLabel.text = @"Water volume:";
		cell.textField.text = [volumeFormatter stringFromNumber:waterVolume];
		cell.tag = kEditableTextCellTagWaterVolume;
		break;

	case kRowMashTunThermalMass:
		cell.textLabel.text = @"Mash tun thermal mass:";
		cell.textField.text = [weightFormatter stringFromNumber:mashTunThermalMass];
		cell.tag = kEditableTextCellTagMashTunThermalMass;
		break;

	case kRowGristTemp:
		cell.textLabel.text = @"Grist temperature:";
		cell.textField.text = [tempFormatter stringFromNumber:gristTemp];
		cell.tag = kEditableTextCellTagGristTemp;
		break;

	default:
		break;
	}

	return cell;
}

- (UITableViewCell *) getStepCellForRow:(int) row {
	NSString *const kMashStepTableCellId = @"MashStepTableCellId";
	MashStepCell *cell = (MashStepCell *)[mashStepsTable dequeueReusableCellWithIdentifier:kMashStepTableCellId];
	if (cell == nil) {
		cell = [TableCellFactory newMashStepCell];
		cell.mashInfo = self;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	NSManagedObject *step = [mashSteps objectAtIndex:row];
	cell.mashStep = step;

	return cell;
}

- (UITableViewCell *) getPlotCell {
	NSString *const kMashPlotCellId = @"MashPlotCellId";
	MashPlotCell *cell = (MashPlotCell *)[mashStepsTable dequeueReusableCellWithIdentifier:kMashPlotCellId];
	if (cell == nil) {
		cell = [TableCellFactory newMashPlotCell];
		cell.mashInfo = self;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	return cell;
}

- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	switch (indexPath.section) {
	case kSectionDetails:
		return [self getDetailsCellForRow:indexPath.row];
		break;

	case kSectionSteps:
		return [self getStepCellForRow:indexPath.row];

	case kSectionVisualization:
		return [self getPlotCell];
		break;

	default:
		return nil;
		break;
	}
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (UITableViewCellEditingStyle)tableView:(UITableView *) tableView editingStyleForRowAtIndexPath:(NSIndexPath *) indexPath {
	switch (indexPath.section) {
	case kSectionSteps:
		return UITableViewCellEditingStyleDelete;
		break;

	default:
		return UITableViewCellEditingStyleNone;
		break;
	}
}

- (UIView *)tableView:(UITableView *) tableView viewForHeaderInSection:(NSInteger) section {
	if (section != kSectionSteps) {
		return nil;
	}

	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DetailsSectionHeader" owner:self options:nil];
	[self.editButton setTitle:mashStepsTable.isEditing ? @"Done":@"Edit" forState:UIControlStateNormal];
	return [nib objectAtIndex:0];
}

- (CGFloat)tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section {
	return 60;
}

- (CGFloat)tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath {
	switch (indexPath.section) {
	case kSectionDetails :
		return 44;
		break;

	case kSectionSteps:
		return 65;
		break;

	case kSectionVisualization:
		return 300;
		break;

	default:
		return 44;
		break;
	}
}

- (void)tableView:(UITableView *) tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *) indexPath {
	[self editStep:[mashSteps objectAtIndex:indexPath.row]];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *) textField {
	UITableViewCell *cell = (UITableViewCell *)[ViewUtils superViewOfView:textField withClass:[UITableViewCell class]];

	switch (cell.tag) {
	case kEditableTextCellTagGristWeight:
		self.gristWeight = [weightFormatter numberFromString:textField.text];
		break;

	case kEditableTextCellTagWaterGristRatio:
		self.waterGristRatio = [densityFormatter numberFromString:textField.text];
		break;

	case kEditableTextCellTagWaterVolume:
		self.waterVolume = [volumeFormatter numberFromString:textField.text];
		break;

	case kEditableTextCellTagMashTunThermalMass:
		self.mashTunThermalMass = [weightFormatter numberFromString:textField.text];
		;
		break;

	case kEditableTextCellTagGristTemp:
		self.gristTemp = [tempFormatter numberFromString:textField.text];
		break;

	default:
		break;
	}
	[mashStepsTable reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *) textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark EditStepDelegate methods

- (void) editStepViewController:(EditStepViewController *) controller didFinishEditing:(NSManagedObject *) step {
	NSManagedObjectContext *context = [(MashMachineAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	if (step == nil) {
		step = [NSEntityDescription insertNewObjectForEntityForName:@"MashStep" inManagedObjectContext:context];
		[step setValue:[NSNumber numberWithInt:[mashSteps count]] forKey:@"stepOrder"];
		[step setValue:detailItem forKey:@"profile"];
	}

	[step setValue:controller.stepName forKey:@"name"];
	[step setValue:[NSNumber numberWithInt:controller.stepType] forKey:@"type"];
	[step setValue:controller.startTemp forKey:@"restStartTemp"];
	[step setValue:controller.endTemp forKey:@"restStopTemp"];
	[step setValue:controller.restTime forKey:@"restTime"];
	[step setValue:controller.stepTime forKey:@"stepTime"];

	switch (controller.stepType) {
	case kMashStepTypeInfusion:
		[step setValue:controller.additionTemp forKey:@"infuseTemp"];
		break;

	case kMashStepTypeDecoction:
		[step setValue:controller.additionTemp forKey:@"decoctTemp"];
		[step setValue:controller.decoctionThickness forKey:@"decoctThickness"];
		[step setValue:controller.boilTime forKey:@"boilTime"];
		break;

	default:
		break;
	}

	[context save:nil];
	[self configureView];
}

@end