//
//  EditStepViewController.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectOneViewController.h"

@class EditStepViewController;
@class NSManagedObject;

@protocol EditStepDelegate

- (void) editStepViewController: (EditStepViewController *)controller didFinishEditing: (NSManagedObject *) step;

@end

@interface EditStepViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SelectOneViewControllerDelegate, UITextFieldDelegate> {
	UITableView *formTable;
	float offsetForKeyboard;
	UITableViewCell *edittedCell;
	
	NSManagedObject *mashStep;
	SelectOneViewController *stepTypeSelector;
	NSNumberFormatter *floatFormatter;
	
	NSString *stepName;
	int stepType;
	NSNumber *startTemp;
	NSNumber *endTemp;
	NSNumber *restTime;
	NSNumber *stepTime;
	NSNumber *additionTemp;
	NSNumber *decoctionThickness;
	
	id<EditStepDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITableView *formTable;
@property (nonatomic, retain) NSManagedObject *mashStep;
@property (nonatomic, assign) int stepType;
@property (nonatomic, copy) NSString *stepName;
@property (nonatomic, copy) NSNumber *startTemp;
@property (nonatomic, copy) NSNumber *endTemp;
@property (nonatomic, copy) NSNumber *restTime;
@property (nonatomic, copy) NSNumber *stepTime;
@property (nonatomic, copy) NSNumber *additionTemp;
@property (nonatomic, copy) NSNumber *decoctionThickness;
@property (nonatomic, retain) NSNumberFormatter *floatFormatter;
@property (nonatomic, assign) id<EditStepDelegate> delegate;

- (IBAction) cancelTouched: (id)sender;
- (IBAction) saveTouched: (id)sender;

@end
