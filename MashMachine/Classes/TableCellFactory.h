//
//  TableCellFactory.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-02.
//  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	kEditableTextCellTagLabel = 1,
	kEditableTextCelLTagTextField
};

enum {
	kEditableTextAndUnitsCellTagLabel = 1,
	kEditableTextAndUnitsCelLTagTextField,
	kEditableTextAndUnitsCelLTagUnitsLabel
};

@class MashStepCell;
@class EditableTextCell;
@class EditableTextAndUnitsCell;
@class MashProfileCell;
@class MashPlotCell;

@interface TableCellFactory : NSObject {
	@private
	TableCellFactory *instance;
	UITableViewCell *editableTextCell;
	UITableViewCell *editableTextAndUnitsCell;
	UITableViewCell *mashStepCell;
	UITableViewCell *mashProfileCell;
	UITableViewCell *mashPlotCell;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *editableTextCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *editableTextAndUnitsCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *mashStepCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *mashProfileCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *mashPlotCell;

+ (EditableTextCell *) newEditableTextCell;
+ (EditableTextAndUnitsCell *) newEditableTextAndUnitsCell;
+ (MashStepCell *) newMashStepCell;
+ (MashProfileCell *) newMashProfileCell;
+ (MashPlotCell *) newMashPlotCell;

@end