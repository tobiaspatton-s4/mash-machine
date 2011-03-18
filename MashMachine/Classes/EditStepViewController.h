//
//  EditStepViewController.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-03.
//  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectOneViewController.h"
#import "IMashInfo.h"

@class EditStepViewController;
@class NSManagedObject;
@class UnitNumberFormater;
@class MashStep;

@protocol EditStepDelegate

- (void) editStepViewController: (EditStepViewController *)controller didFinishEditing: (MashStep *) step;

@end

@interface EditStepViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SelectOneViewControllerDelegate, UITextFieldDelegate> {
	UITableView *formTable;
	float offsetForKeyboard;
	UITableViewCell *edittedCell;
	
	MashStep *mashStep;
	SelectOneViewController *stepTypeSelector;
	
	NSString *stepName;
	int stepType;
	NSNumber *startTemp;
	NSNumber *endTemp;
	NSNumber *restTime;
	NSNumber *stepTime;
	NSNumber *additionTemp;
	NSNumber *decoctionThickness;
	NSNumber *boilTime;
	
	id<EditStepDelegate> delegate;
	id<IMashInfo> mashInfo;
}

@property (nonatomic, retain) IBOutlet UITableView *formTable;
@property (nonatomic, retain) MashStep *mashStep;
@property (nonatomic, assign) int stepType;
@property (nonatomic, copy) NSString *stepName;
@property (nonatomic, copy) NSNumber *startTemp;
@property (nonatomic, copy) NSNumber *endTemp;
@property (nonatomic, copy) NSNumber *restTime;
@property (nonatomic, copy) NSNumber *stepTime;
@property (nonatomic, copy) NSNumber *additionTemp;
@property (nonatomic, copy) NSNumber *decoctionThickness;
@property (nonatomic, copy) NSNumber *boilTime;
@property (nonatomic, assign) id<EditStepDelegate> delegate;
@property (nonatomic, assign) id<IMashInfo> mashInfo;

- (IBAction) cancelTouched: (id)sender;
- (IBAction) saveTouched: (id)sender;

@end
