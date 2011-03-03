//
//  MashStepCell.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSManagedObject;

@interface MashStepCell : UITableViewCell {
	NSManagedObject *mashStep;
}

@property (readonly) UILabel *timeAndTempLabel;
@property (nonatomic, retain) NSManagedObject *mashStep;

@end
