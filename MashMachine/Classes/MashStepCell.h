//
//  MashStepCell.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-02.
//  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMashInfo.h"

@class MashStep;
@class NSManagedObject;

@interface MashStepCell : UITableViewCell {
	@private
	MashStep *mashStep;
	id<IMashInfo> mashInfo;
}

@property (readonly) UILabel *timeAndTempLabel;
@property (nonatomic, retain) MashStep *mashStep;
@property (nonatomic, assign) id<IMashInfo> mashInfo;

@end
