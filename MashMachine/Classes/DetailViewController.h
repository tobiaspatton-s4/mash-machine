//
//  DetailViewController.h
//  MashMachine
//
//  Created by Tobias Patton on 11-02-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "IMashInfo.h"
#import "EditStepViewController.h"

@class RootViewController;
@class UnitNumberFormater;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, IMashInfo, EditStepDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;	
	UILabel *toolbarTitle;
	UITableView *mashStepsTable;	
    RootViewController *rootViewController;
	UIButton *editButton;
	
    NSManagedObject *detailItem;
	NSArray *mashSteps;
	
	NSNumberFormatter *floatFormatter;
	UnitNumberFormater *weightFormatter;
	
	NSNumber *gristWeight;
	NSNumber *waterGristRatio;
	NSNumber *waterVolume;
	NSNumber *mashTunThermalMass;
	NSNumber *gristTemp;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UILabel *toolbarTitle;
@property (nonatomic, retain) NSManagedObject *detailItem;
@property (nonatomic, retain) NSArray *mashSteps;
@property (nonatomic, assign) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UITableView *mashStepsTable;
@property (nonatomic, retain) IBOutlet UIButton *editButton;

@property (nonatomic, retain) NSNumberFormatter *floatFormatter;
@property (nonatomic, retain) UnitNumberFormater *weightFormatter;

@property (nonatomic, copy) NSNumber *gristWeight;
@property (nonatomic, copy) NSNumber *waterGristRatio;
@property (nonatomic, copy) NSNumber *waterVolume;
@property (nonatomic, copy) NSNumber *mashTunThermalMass;
@property (nonatomic, copy) NSNumber *gristTemp;

- (IBAction) addStepTouched: (id)sender;
- (IBAction) editTouched: (id)sender;

@end
