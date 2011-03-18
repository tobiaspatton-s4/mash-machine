//
//  MashMachineAppDelegate.h
//  MashMachine
//
//  Created by Tobias Patton on 11-02-22.
//  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@class RootViewController;
@class DetailViewController;

@interface MashMachineAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;

	UISplitViewController *splitViewController;
	UINavigationController *navigationController;
	RootViewController *rootViewController;
	DetailViewController *detailViewController;

@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

- (NSObject *) dataBaseInfoForKey: (NSString *)key;
- (void) setDataBaseInfo: (NSObject *)value forKey:(NSString *)key;
@end
