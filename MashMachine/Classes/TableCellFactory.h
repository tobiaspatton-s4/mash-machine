//
//  TableCellFactory.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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

@interface TableCellFactory : NSObject {
	@private
	TableCellFactory *instance;
	UITableViewCell *editableTextCell;
	UITableViewCell *editableTextAndUnitsCell;
	UITableViewCell *mashStepCell;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *editableTextCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *editableTextAndUnitsCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *mashStepCell;

+ (EditableTextCell *) newEditableTextCell;
+ (EditableTextAndUnitsCell *) newEditableTextAndUnitsCell;
+ (MashStepCell *) newMashStepCell;

@end