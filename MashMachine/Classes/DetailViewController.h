//
//  DetailViewController.h
//  MashMachine
//
//  Created by Tobias Patton on 11-02-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class RootViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;	
	UILabel *toolbarTitle;
	UITableView *mashStepsTable;	
    RootViewController *rootViewController;
	
    NSManagedObject *detailItem;
	NSArray *mashSteps;
	
	NSNumberFormatter *floatFormatter;
	
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

@property (nonatomic, retain) NSNumberFormatter *floatFormatter;

@property (nonatomic, copy) NSNumber *gristWeight;
@property (nonatomic, copy) NSNumber *waterGristRatio;
@property (nonatomic, copy) NSNumber *waterVolume;
@property (nonatomic, copy) NSNumber *mashTunThermalMass;
@property (nonatomic, copy) NSNumber *gristTemp;

- (IBAction)insertNewObject:(id)sender;

@end
