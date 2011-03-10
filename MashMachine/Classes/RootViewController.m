//
//  RootViewController.m
//  MashMachine
//
//  Created by Tobias Patton on 11-02-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "TableCellFactory.h"
#import "MashProfileCell.h"
#import "ViewUtils.h"
#import "MashMachineAppDelegate.h"

/*
 This template does not ensure user interface consistency during editing operations in the table view. You must implement appropriate methods to provide the user experience you require.
 */

@interface RootViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation RootViewController

@synthesize detailViewController, fetchedResultsController, managedObjectContext, addedObjectId;

- (IBAction) addProfileTouched: (id)sender {
	NSManagedObjectContext *context = [(MashMachineAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	NSManagedObject *profile = [NSEntityDescription insertNewObjectForEntityForName:@"MashProfile" inManagedObjectContext:context];	
	
	[profile setValue:@"New Profile" forKey:@"name"];
	[profile setValue:NO forKey:@"builtIn"];
	[profile setValue:[NSDate date] forKey:@"creationDate"];
	[profile setValue:[NSDate date] forKey:@"modificationDate"];
	
	NSError *error = nil;
	[context save:&error];
	
	self.addedObjectId = profile.objectID;
	[self.fetchedResultsController performFetch:nil];
	
	for (int i = 0; i <[[self.fetchedResultsController fetchedObjects] count]; i++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
		if (mo.objectID == profile.objectID) {
			[[[self editButtonItem] target] performSelector:[[self editButtonItem] action]];
			MashProfileCell *cell = (MashProfileCell *)[self.tableView cellForRowAtIndexPath:indexPath];
			[cell.textField becomeFirstResponder];
		}
	}
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	self.navigationItem.title = @"Mash Profiles";
	self.navigationItem.leftBarButtonItem = [self editButtonItem];

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.    
    return YES;
}


- (void)configureCell:(MashProfileCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textField.font = [UIFont systemFontOfSize:18];
	cell.textField.adjustsFontSizeToFitWidth = YES;
    cell.textField.text = [managedObject valueForKey:@"name"];
	cell.textField.delegate = self;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d steps", [[managedObject valueForKey:@"steps"] count]];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MashProfileCell";
    
    MashProfileCell *cell = (MashProfileCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [TableCellFactory newMashProfileCell];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        NSManagedObject *objectToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (self.detailViewController.detailItem == objectToDelete) {
            self.detailViewController.detailItem = nil;
        }
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:objectToDelete];
        
        NSError *error;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

#pragma mark -
#pragma mark Table view delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Set the detail item in the detail view controller.
    NSManagedObject *selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.detailViewController.detailItem = selectedObject;    
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MashProfile" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    return fetchedResultsController;
}    


#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    
    [detailViewController release];
    [fetchedResultsController release];
    [managedObjectContext release];
	[addedObjectId release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	UITableViewCell *cell = (UITableViewCell *)[ViewUtils superViewOfView:textField withClass:[UITableViewCell class]];
	NSIndexPath *path = [self.tableView indexPathForCell:cell];
	NSManagedObject *profile = [self.fetchedResultsController objectAtIndexPath:path];
	[profile setValue:textField.text forKey:@"name"];
	[managedObjectContext save:nil];
}

@end
