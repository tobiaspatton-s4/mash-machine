//
//  EditStepViewController.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>;

#import "EditStepViewController.h"
#import "EditableTextAndUnitsCell.h"
#import "Constants.h"
#import "TableCellFactory.h"
#import "EditableTextCell.h"
#import "SelectOneViewController.h"
#import "ViewUtils.h"
#import "UnitConverter.h"

enum {
	kRowStepName = 0,
	kRowStepType,
	kRowStartTemp,
	kRowEndTemp,
	kRowStepTime,
	kRowRestTime,
	kRowAdditionTemp,
	kRowDecoctThickness
};

enum {
	kTableCellTagStepName = 1000,
	kTableCellTagStartTemp,
	kTableCellTagEndTemp,
	kTableCellTagRestTime,
	kTableCellTagStepTime,
	kTableCellTagAdditionTemp,
	kTableCellTagDecoctThickness
};

static NSArray *MashStepTypes;

@interface EditStepViewController ()

@property (nonatomic, retain) SelectOneViewController *stepTypeSelector;

- (void) configureUI;
- (UITableViewCell *) tableView:(UITableView *) tableView editableTextCellForRow:(int) row;
- (UITableViewCell *) tableView:(UITableView *) tableView itemSelectionCellForRow:(int) row;

@end

@implementation EditStepViewController

@synthesize mashStep;
@synthesize stepType;
@synthesize formTable;
@synthesize stepTypeSelector;
@synthesize stepName;
@synthesize startTemp;
@synthesize endTemp;
@synthesize restTime;
@synthesize stepTime;
@synthesize additionTemp;
@synthesize decoctionThickness;
@synthesize delegate;
@synthesize mashInfo;

+ (void) initialize {
	MashStepTypes = [[NSArray alloc] initWithObjects:@"Direct heat", @"Infusion", @"Decoction", nil];
}

- (void) setMashStep:(NSManagedObject *) value {
	[mashStep autorelease];
	mashStep = [value retain];
	if (mashStep == nil) {
		self.stepType = kMashStepTypeInfusion;
		self.stepName = @"New Step";
		self.startTemp = [NSNumber numberWithFloat:150.0];
		self.endTemp = [NSNumber numberWithFloat:150.0];
		self.restTime = [NSNumber numberWithFloat:60.0];
		self.stepTime = [NSNumber numberWithFloat:5.0];
		self.additionTemp = [NSNumber numberWithFloat:212.0];
		self.decoctionThickness = [NSNumber numberWithFloat:1.3];
	}
	else {
		self.stepType = [(NSNumber *)[mashStep valueForKey:@"type"] intValue];
		self.stepName = [mashStep valueForKey:@"name"];
		self.startTemp = [mashStep valueForKey:@"restStartTemp"];
		self.endTemp = [mashStep valueForKey:@"restStopTemp"];
		self.restTime = [mashStep valueForKey:@"restTime"];
		self.stepTime = [mashStep valueForKey:@"stepTime"];
		if (stepType == kMashStepTypeInfusion) {
			self.additionTemp = [mashStep valueForKey:@"infuseTemp"];
		}
		else if (stepType == kMashStepTypeDecoction) {
			self.additionTemp = [mashStep valueForKey:@"decoctTemp"];
			self.decoctionThickness = [mashStep valueForKey:@"decoctThickness"];
		}
	}

	[self configureUI];
}

- (void) keyboardDidAppear:(NSNotification *) notification {
	NSDictionary *info = [notification userInfo];
	NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardFrame = [aValue CGRectValue];
	CGRect adjustedKeyboardFrame = [formTable.superview convertRect:keyboardFrame fromView:nil];

	CGRect tableFrame = formTable.frame;
	offsetForKeyboard = tableFrame.size.height - adjustedKeyboardFrame.origin.y;

	tableFrame.size.height -= offsetForKeyboard;
	formTable.frame = tableFrame;

	NSIndexPath *indexPath = [formTable indexPathForCell:edittedCell];
	[formTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void) keyboardWillDisappear:(NSNotification *) notification {
	CGRect tableFrame = formTable.frame;
	tableFrame.size.height += offsetForKeyboard;
	formTable.frame = tableFrame;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
	                                                                                       target:self
	                                                                                       action:@selector(cancelTouched:)] autorelease];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
	                                                                                        target:self
	                                                                                        action:@selector(saveTouched:)] autorelease];

	[self configureUI];
}

- (void) viewDidAppear:(BOOL) animated {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidDisappear:(BOOL) animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction) cancelTouched:(id) sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) saveTouched:(id) sender {
	[self dismissModalViewControllerAnimated:YES];
	[delegate editStepViewController:self didFinishEditing:mashStep];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
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
}

- (void)dealloc {
	[mashStep release];
	[stepTypeSelector release];
	[formTable release];
	[stepName release];
	[startTemp release];
	[endTemp release];
	[restTime release];
	[stepTime release];
	[additionTemp release];
	[decoctionThickness release];
	[super dealloc];
}

- (void) configureUI {
	if (mashStep == nil) {
		return;
	}

	self.navigationItem.title = [mashStep valueForKey:@"name"];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSString *)tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
	return @"Step Details";
}

- (NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	int stepNum;

	switch (stepType) {
	case kMashStepTypeDirectHeat:
		return 6;
		break;

	case kMashStepTypeInfusion:
		stepNum = [(NSNumber *)[mashStep valueForKey:@"stepOrder"] intValue];
		if (stepNum == 0) {
			// does not have infusion temperature -- this is calculated for the first step
			return 6;
		}
		return 7;
		break;

	case kMashStepTypeDecoction:
		return 8;
		break;

	default:
		return 0;
		break;
	}
}

- (UITableViewCell *) tableView:(UITableView *) tableView editableTextCellForRow:(int) row {
	NSString *const kEditableTextCell = @"EditableTextCell";
	EditableTextCell *cell = (EditableTextCell *)[tableView dequeueReusableCellWithIdentifier:kEditableTextCell];

	if (cell == nil) {
		cell = [TableCellFactory newEditableTextCell];
	}

	switch (row) {
	case kRowStepName:
		cell.textLabel.text = @"Step name:";
		cell.tag = kTableCellTagStepName;
		cell.textField.text = stepName;
		cell.textField.delegate = self;
		break;

	case kRowRestTime:
		cell.textLabel.text = @"Rest time:";
		cell.tag = kTableCellTagRestTime;
		cell.textField.text = [mashInfo.timeFormatter stringFromNumber:restTime];
		cell.textField.delegate = self;
		break;

	case kRowStepTime:
		cell.textLabel.text = @"Rise time:";
		cell.tag = kTableCellTagStepTime;
		cell.textField.text = [mashInfo.timeFormatter stringFromNumber:stepTime];
		cell.textField.delegate = self;
		break;

	case kRowStartTemp:
		cell.textLabel.text = @"Temperature at start:";
		cell.tag = kTableCellTagStartTemp;
		cell.textField.text = [mashInfo.tempFormatter stringFromNumber:startTemp];
		cell.textField.delegate = self;
		break;

	case kRowEndTemp:
		cell.textLabel.text = @"Temperature at end:";
		cell.tag = kTableCellTagEndTemp;
		cell.textField.text = [mashInfo.tempFormatter stringFromNumber:endTemp];
		cell.textField.delegate = self;
		break;

	case kRowAdditionTemp:
		if (stepType == kMashStepTypeInfusion) {
			cell.textLabel.text = @"Infusion temperature:";
		}
		else if (stepType == kMashStepTypeDecoction) {
			cell.textLabel.text = @"Decoction temperature:";
		}
		cell.tag = kTableCellTagAdditionTemp;
		cell.textField.text = [mashInfo.tempFormatter stringFromNumber:additionTemp];
		cell.textField.delegate = self;
		break;

	case kRowDecoctThickness:
		cell.textLabel.text = @"Decoction thickness:";
		cell.tag = kTableCellTagDecoctThickness;
		cell.textField.text = [mashInfo.densityFormatter stringFromNumber:decoctionThickness];
		cell.textField.delegate = self;
		break;

	default:
		break;
	}
	return cell;
}

- (UITableViewCell *) tableView:(UITableView *) tableView itemSelectionCellForRow:(int) row {
	NSString *const kItemSelectionCell = @"ItemSelectionCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kItemSelectionCell];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kItemSelectionCell] autorelease];
	}

	switch (row) {
	case kRowStepType:
		cell.textLabel.text = @"Step type:";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.detailTextLabel.text = [MashStepTypes objectAtIndex:stepType];
		break;

	default:
		break;
	}

	return cell;
}

- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	UITableViewCell *cell = nil;
	switch (indexPath.row) {
	case kRowStepName:
	case kRowStepTime:
	case kRowRestTime:
	case kRowStartTemp:
	case kRowEndTemp:
	case kRowAdditionTemp:
		cell = [self tableView:tableView editableTextCellForRow:indexPath.row];
		break;

	case kRowStepType:
		cell = [self tableView:tableView itemSelectionCellForRow:kRowStepType];
		break;

	case kRowDecoctThickness:
		cell = [self tableView:tableView editableTextCellForRow:indexPath.row];
		break;

	default:
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dummy"] autorelease];
		break;
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (NSIndexPath *)tableView:(UITableView *) tableView willSelectRowAtIndexPath:(NSIndexPath *) indexPath {
	if (indexPath.row == kRowStepType) {
		SelectOneViewController *controller = [[[SelectOneViewController alloc] init] autorelease];
		controller.options = MashStepTypes;
		controller.labelPath = nil;
		controller.selectedIndex = stepType;
		controller.title = @"Select Step Type";
		controller.delegate = self;

		self.stepTypeSelector = controller;
		[self.navigationController pushViewController:controller animated:YES];
	}
	return nil;
}

#pragma mark -
#pragma mark SelectOneViewControllerDelegate methods

- (void) selectOneViewController:(SelectOneViewController *) controller didSelectOptionAtIndex:(int) index {
	[controller.navigationController popViewControllerAnimated:YES];

	if (controller == stepTypeSelector) {
		stepType = controller.selectedIndex;
	}

	[formTable reloadData];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *) textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *) textField {
	edittedCell = (UITableViewCell *)[ViewUtils superViewOfView:textField withClass:[UITableViewCell class]];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *) textField {
	UITableViewCell *cell = (UITableViewCell *)[ViewUtils superViewOfView:textField withClass:[UITableViewCell class]];
	switch (cell.tag) {
	case kTableCellTagStepName:
		self.stepName = textField.text;
		break;

	case kTableCellTagStartTemp:
		self.startTemp = [mashInfo.tempFormatter numberFromString:textField.text];
		self.endTemp = self.startTemp;
		break;

	case kTableCellTagEndTemp:
		self.endTemp = [mashInfo.tempFormatter numberFromString:textField.text];
		break;

	case kTableCellTagRestTime:
		self.restTime = [mashInfo.timeFormatter numberFromString:textField.text];
		break;

	case kTableCellTagStepTime:
		self.stepTime = [mashInfo.timeFormatter numberFromString:textField.text];
		break;

	case kTableCellTagAdditionTemp:
		self.additionTemp = [mashInfo.tempFormatter numberFromString:textField.text];
		break;

	case kTableCellTagDecoctThickness:
		self.decoctionThickness = [mashInfo.densityFormatter numberFromString:textField.text];
		break;

	default:
		break;
	}

	[formTable reloadData];
}

@end