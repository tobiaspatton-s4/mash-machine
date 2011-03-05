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

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
- (UITableViewCell *) getDetailsCellForRow:(int) row;
- (UITableViewCell *) getStepCellForRow:(int) row;
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
	kSectionSteps
};

enum {
	kRowGristWeight,
	kRowGristTemp,
	kRowWaterVolume,
	kRowWaterGristRatio,
	kRowMashTunThermalMass};

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
@synthesize floatFormatter;
@synthesize gristTemp;
@synthesize toolbarTitle;

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

- (void) addStep: (MashStep *) step {
	
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

/*
   // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
   - (void)viewDidLoad {
    [super viewDidLoad];
   }
 */

/*
   - (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   }
 */
/*
   - (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   }
 */
/*
   - (void)viewWillDisappear:(BOOL)animated {
        [super viewWillDisappear:animated];
   }
 */
/*
   - (void)viewDidDisappear:(BOOL)animated {
        [super viewDidDisappear:animated];
   }
 */

- (id) initWithCoder:(NSCoder *) aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.gristWeight = [NSNumber numberWithFloat:10.0];
		self.mashTunThermalMass = [NSNumber numberWithFloat:2.0];
		self.waterVolume = [NSNumber numberWithFloat:15.0];
		self.waterGristRatio = [NSNumber numberWithFloat:1.5];
		self.gristTemp = [NSNumber numberWithFloat:60];

		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setMaximumFractionDigits:1];
		[formatter setMinimumFractionDigits:1];
		[formatter setMinimumIntegerDigits:1];
		[formatter setPaddingCharacter:@"0"];
		self.floatFormatter = formatter;
		[formatter release];
	}
	return self;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.detailItem = nil;
	self.mashSteps = nil;
	self.toolbar = nil;
	self.toolbarTitle = nil;
	self.popoverController = nil;
	self.mashStepsTable = nil;
	self.gristWeight = nil;
	self.waterVolume = nil;
	self.waterGristRatio = nil;
	self.mashTunThermalMass = nil;
	self.floatFormatter = nil;
	self.gristTemp = nil;
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
	[floatFormatter release];
	[gristTemp release];

	[super dealloc];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *) tableView {
	if (detailItem == nil) {
		return 0;
	}
	return 2;
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

	default:
		return @"";
		break;
	}
}

- (UITableViewCell *) getDetailsCellForRow:(int) row {
	NSString *const kDetailsTableCellId = @"EditableTextAndUnitsCell";
	EditableTextAndUnitsCell *cell = (EditableTextAndUnitsCell *)[mashStepsTable dequeueReusableCellWithIdentifier:kDetailsTableCellId];

	if (cell == nil) {
		cell = [TableCellFactory newEditableTextAndUnitsCell];
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	cell.textField.delegate = self;
	cell.textField.keyboardType = UIKeyboardTypeNumberPad;

	switch (row) {
	case kRowGristWeight:
		cell.textLabel.text = @"Grist weight:";
		cell.textField.text = [floatFormatter stringFromNumber:gristWeight];
		cell.unitsLabel.text = @"lb";
		cell.tag = kEditableTextCellTagGristWeight;
		break;

	case kRowWaterGristRatio:
		cell.textLabel.text = @"Water/grist ratio:";
		cell.textField.text = [floatFormatter stringFromNumber:waterGristRatio];
		cell.unitsLabel.text = @"qt/lb";
		cell.tag = kEditableTextCellTagWaterGristRatio;
		break;

	case kRowWaterVolume:
		cell.textLabel.text = @"Water volume:";
		cell.textField.text = [floatFormatter stringFromNumber:waterVolume];
		cell.unitsLabel.text = @"qt";
		cell.tag = kEditableTextCellTagWaterVolume;
		break;

	case kRowMashTunThermalMass:
		cell.textLabel.text = @"Mash tun thermal mass:";
		cell.textField.text = [floatFormatter stringFromNumber:mashTunThermalMass];
		cell.unitsLabel.text = @"lb";
		cell.tag = kEditableTextCellTagMashTunThermalMass;
		break;

	case kRowGristTemp:
		cell.textLabel.text = @"Grist temperature:";
		cell.textField.text = [floatFormatter stringFromNumber:gristTemp];
		cell.unitsLabel.text = @"F";
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

- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	switch (indexPath.section) {
	case kSectionDetails:
		return [self getDetailsCellForRow:indexPath.row];
		break;

	case kSectionSteps:
		return [self getStepCellForRow:indexPath.row];

	default:
		return nil;
		break;
	}
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath {
	switch (indexPath.section) {
	case kSectionDetails:
		return 44;
		break;

	case kSectionSteps:
		return 65;
		break;

	default:
		return 44;
		break;
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *step = [mashSteps objectAtIndex:indexPath.row];
	EditStepViewController *controller = [[[EditStepViewController alloc] init] autorelease];
	controller.mashStep = step;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	navController.modalPresentationStyle = UIModalPresentationFormSheet;
	navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:navController animated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *) textField {
	UITableViewCell *cell = (UITableViewCell *)[ViewUtils superViewOfView:textField withClass:[UITableViewCell class]];
	NSNumber *value = [floatFormatter numberFromString:textField.text];

	if (value != nil) {
		switch (cell.tag) {
			case kEditableTextCellTagGristWeight:
				self.gristWeight = value;
				break;

			case kEditableTextCellTagWaterGristRatio:
				self.waterGristRatio = value;
				break;

			case kEditableTextCellTagWaterVolume:
				self.waterVolume = value;
				break;

			case kEditableTextCellTagMashTunThermalMass:
				self.mashTunThermalMass = value;
				break;

			case kEditableTextCellTagGristTemp:
				self.gristTemp = value;
				break;

			default:
				break;
		}
	}
	[mashStepsTable reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

@end