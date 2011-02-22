//
//  DetailViewController.m
//  MashMachine
//
//  Created by Tobias Patton on 11-02-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
- (UITableViewCell *) getDetailsCellForRow: (int)row;
- (UITableViewCell *) getStepCellForRow: (int)row;
@end


enum {
	kSectionDetails,
	kSectionSteps
};

enum {
	kRowGristWeight,
	kRowWaterVolumn,
	kRowWaterGristRatio
};

@implementation DetailViewController

@synthesize toolbar, popoverController, detailItem, rootViewController, mashSteps, mashStepsTable;


#pragma mark -
#pragma mark Object insertion

- (IBAction)insertNewObject:(id) sender {
	[self.rootViewController insertNewObject:sender];
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

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.detailItem = nil;
	self.mashSteps = nil;
	self.toolbar = nil;
	self.popoverController = nil;
	self.mashStepsTable = nil;
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
	[detailItem release];
	[mashSteps release];
	[mashStepsTable release];

	[super dealloc];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
			return 3;
			break;
		case kSectionSteps:
			return [mashSteps count];
			break;
		default:
			return 0;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
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

- (UITableViewCell *) getDetailsCellForRow: (int)row {
	NSString *const kDetailsTableCellId = @"DetailsTableCellId";
	UITableViewCell *cell = [mashStepsTable dequeueReusableCellWithIdentifier:kDetailsTableCellId];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kDetailsTableCellId] autorelease];
	}
		
	return cell;	
}

- (UITableViewCell *) getStepCellForRow: (int)row {
	NSString *const kMashStepTableCellId = @"MashStepTableCellId";
	UITableViewCell *cell = [mashStepsTable dequeueReusableCellWithIdentifier:kMashStepTableCellId];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kMashStepTableCellId] autorelease];
	}
	
	NSManagedObject *step = [mashSteps objectAtIndex:row];
	cell.textLabel.text = [step valueForKey:@"name"];
	
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

@end