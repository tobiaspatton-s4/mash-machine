//
//  DatabaseUtils.h
//  BrewPad
//
//  Created by Tobias Patton on 11-02-21.
//  Copyright 2011 Blue Cedar Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;
@class NSManagedObject;

@interface DatabaseUtils : NSObject {
}

+ (void) deleteBuiltInItemsFromEntity: (NSString *)entityName inContext: (NSManagedObjectContext *) context;
+ (NSMutableSet *) managedObjectsFromArray:(NSArray *)array withEntityName:(NSString *)entityName inContext: (NSManagedObjectContext *) context;
+ (void) installDataFromPlist:(NSString *) fileName intoContext:(NSManagedObjectContext *) context;

@end