//
//  RootViewController.h
//  MashMachine
//
//  Created by Tobias Patton on 11-02-22.
//  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@class DetailViewController;

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate> {
    
    DetailViewController *detailViewController;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
	
	NSManagedObjectID *addedObjectId; 
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectID *addedObjectId; 

- (IBAction) addProfileTouched: (id)sender;
@end
