    //
//  SelectOneViewController.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-04.
//  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
//

#import "SelectOneViewController.h"


@implementation SelectOneViewController

@synthesize options;
@synthesize selectedIndex;
@synthesize labelPath;
@synthesize delegate;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
	self.options = nil;
	self.labelPath = nil;
}


- (void)dealloc {
	[options release];
	[labelPath release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *const kCellId = @"SelectOneTableViewCellId";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellId] autorelease];
	}
	
	if (labelPath == nil) {
		cell.textLabel.text = [[options objectAtIndex:indexPath.row] description];
	}
	else {
		cell.textLabel.text = [[options objectAtIndex:indexPath.row] valueForKey:self.labelPath];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = indexPath.row == selectedIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selectedIndex = indexPath.row;
	[tableView reloadData];
	[delegate selectOneViewController:self didSelectOptionAtIndex:indexPath.row];
	return nil;
}

@end
