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

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
    NSManagedObject *detailItem;
	NSArray *mashSteps;
	
	UITableView *mashStepsTable;
	
    RootViewController *rootViewController;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) NSManagedObject *detailItem;
@property (nonatomic, retain) NSArray *mashSteps;
@property (nonatomic, assign) IBOutlet RootViewController *rootViewController;
@property (nonatomic, assign) IBOutlet UITableView *mashStepsTable;

- (IBAction)insertNewObject:(id)sender;

@end
