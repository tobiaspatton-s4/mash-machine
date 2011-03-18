//
//  MashMachineAppDelegate.m
//  MashMachine
//
//  Created by Tobias Patton on 11-02-22.
//  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
//

#import "MashMachineAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"
#import "DatabaseUtils.h"
#import "UnitConverter.h"

@interface MashMachineAppDelegate ()

- (void) installDefaultDataIfNeeded;
- (NSManagedObject *) dataBaseInfoManagedObjectForKey: (NSString *) key;

@end

@implementation MashMachineAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController, navigationController;


- (NSManagedObject *) dataBaseInfoManagedObjectForKey: (NSString *) key {
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DatabaseInfo" 
											  inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity: entity];
	
	NSError *error = nil;
	NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if (result == nil) {
		ALog(@"Error getting dataBaseInfo value: %d %@", [error code], [error localizedDescription]);
		return nil;
	}
	
	if ([result count] == 0) {
		return nil;
	}
	
	return (NSManagedObject *)[result objectAtIndex:0];
}

- (NSObject *) dataBaseInfoForKey: (NSString *) key {
	NSManagedObject *object = [self dataBaseInfoManagedObjectForKey:key];	
	return [object valueForKey:key];
}

- (void) setDataBaseInfo: (NSObject* )value forKey:(NSString *)key {
	NSManagedObject *object = [self dataBaseInfoManagedObjectForKey:key];
	if (object == nil) {
		object = [NSEntityDescription insertNewObjectForEntityForName:@"DatabaseInfo" 
											   inManagedObjectContext:self.managedObjectContext];
	}
	[object setValue:value forKey:key];
	[self.managedObjectContext save:nil];
}

- (void) installDefaultDataIfNeeded {
	NSNumber *defaultsLoaded = (NSNumber *)[self dataBaseInfoForKey:@"defaultsLoaded"];
	
	if (![defaultsLoaded boolValue]) {
		[DatabaseUtils installDataFromPlist:@"MashProfile" 
								intoContext:self.managedObjectContext];		
		[self setDataBaseInfo: [NSNumber numberWithBool:YES] forKey:@"defaultsLoaded"];
	}
}

#pragma mark -
#pragma mark Application lifecycle


- (void)awakeFromNib {
    // Pass the managed object context to the root view controller.
    rootViewController.managedObjectContext = self.managedObjectContext; 
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch.
	[self installDefaultDataIfNeeded];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:kUnitQuart], @"prefUnitsVolume",
							  [NSNumber numberWithInt:kUnitPound], @"prefUnitsWeight",
							  [NSNumber numberWithInt:kUnitFahrenheit], @"prefUnitsTemperature",
							  [NSNumber numberWithInt:kUnitQuartsPerPound], @"prefUnitsDensity",
							  nil]];
    [prefs synchronize];
	
	// Add the split view controller's view to the window and display.
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[self.window addSubview:splitViewController.view];		
	}
	else {
		[self.window addSubview:navigationController.view];
	}
    [self.window makeKeyAndVisible];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MashMachine" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MashMachine.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {

    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    [navigationController release];
	[splitViewController release];
	[rootViewController release];
	[detailViewController release];

	[window release];
	[super dealloc];
}


@end

