//
//  Entities.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-17.
//  Copyright 2011 Blue Cedar Creative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MashProfile : NSManagedObject

@property (nonatomic, retain) NSNumber * builtIn;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* steps;
@end

@interface MashProfile (CoreDataGeneratedAccessors)
- (void)addStepsObject:(NSManagedObject *)value;
- (void)removeStepsObject:(NSManagedObject *)value;
- (void)addSteps:(NSSet *)value;
- (void)removeSteps:(NSSet *)value;
@end

@interface MashStep : NSManagedObject
@property (nonatomic, retain) NSNumber * boilTime;
@property (nonatomic, retain) NSNumber * decoctTemp;
@property (nonatomic, retain) NSNumber * decoctThickness;
@property (nonatomic, retain) NSNumber * infuseTemp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * restStartTemp;
@property (nonatomic, retain) NSNumber * restStopTemp;
@property (nonatomic, retain) NSNumber * restTime;
@property (nonatomic, retain) NSNumber * stepOrder;
@property (nonatomic, retain) NSNumber * stepTime;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSManagedObject * profile;
@end
