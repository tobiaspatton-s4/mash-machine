//
//  DatabaseUtils.m
//  BrewPad
//
//  Created by Tobias Patton on 11-02-21.
//  Copyright 2011 Blue Cedar Creative. All rights reserved.
//

#import "DatabaseUtils.h"
#import <CoreData/CoreData.h>

@implementation DatabaseUtils

+ (void) deleteBuiltInItemsFromEntity:(NSString *) entityName inContext:(NSManagedObjectContext *) context {
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"builtIn == 1"];
	[request setEntity:entity];
	[request setPredicate:predicate];

	NSError *error = nil;
	NSArray *result = [context executeFetchRequest:request error:&error];
	if (result == nil) {
		ALog(@"Error getting builtIn items from entity named %@: %d %@", entityName, [error code], [error localizedDescription]);
		return;
	}

	for (NSManagedObject *obj in result) {
		[context deleteObject:obj];
	}

	BOOL success = [context save:&error];
	if (!success) {
		ALog(@"Error saving context: %d %@", [error code], [error localizedDescription]);
	}
}

+ (NSMutableSet *) managedObjectsFromArray:(NSArray *) array
							withEntityName:(NSString *) entityName 
								 inContext: (NSManagedObjectContext *) context {
	NSMutableSet *result = [NSMutableSet set];

	for (NSObject *object in array) {
		if (![object isKindOfClass:[NSDictionary class]]) {
			continue;
		}
		
		NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName
																	   inManagedObjectContext:context];
		NSDictionary *objectDict = (NSDictionary *)object;
		NSEnumerator *keyEnumerator = [objectDict keyEnumerator];
		NSString *key = nil;

		while (key = [keyEnumerator nextObject]) {
			NSObject *obj = [objectDict valueForKey:key];
			if ([obj isKindOfClass:[NSArray class]]) {
				NSRelationshipDescription *relation = [[[managedObject entity] relationshipsByName] objectForKey:key];
				NSEntityDescription *destEntity = [relation destinationEntity];
				NSSet *relationshipSet = [self managedObjectsFromArray:(NSArray *)obj withEntityName:destEntity.name inContext:context];
				[managedObject setValue:relationshipSet forKey:key];
			}
			else {
				[managedObject setValue:obj forKey:key];
			}
			[result addObject:managedObject];
		}
	}

	return result;
}

+ (void) installDataFromPlist:(NSString *) fileName intoContext:(NSManagedObjectContext *) context {
	NSError *error = nil;
	DLog(@"Adding data from %@.plist", fileName);
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	if (plistPath == nil) {
		ALog("Could not find plist file with name %@.plist", fileName);
		return;
	}

	NSArray *plistArray = [NSArray arrayWithContentsOfFile:plistPath];
	if (plistArray == nil) {
		ALog("Could not open %@.plist as an NSArray", fileName);
		return;
	}

	[self managedObjectsFromArray:plistArray withEntityName:fileName inContext:context];

	error = nil;
	BOOL success = [context save:&error];
	if (!success) {
		ALog(@"Error saving context: %d %@", [error code], [error localizedDescription]);
	}
	[error release];
}

@end