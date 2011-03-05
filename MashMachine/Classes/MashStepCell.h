//
//  MashStepCell.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMashInfo.h"

@class NSManagedObject;

@interface MashStepCell : UITableViewCell {
	@private
	NSManagedObject *mashStep;
	id<IMashInfo> mashInfo;
	NSNumberFormatter *floatFormatter;
}

@property (readonly) UILabel *timeAndTempLabel;
@property (nonatomic, retain) NSManagedObject *mashStep;
@property (nonatomic, assign) id<IMashInfo> mashInfo;
@property (nonatomic, retain) NSNumberFormatter *floatFormatter;

@end
