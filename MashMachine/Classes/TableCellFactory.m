//
//  TableCellFactory.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditableTextCell.h"
#import "TableCellFactory.h"
#import "MashStepCell.h"
#import "EditableTextAndUnitsCell.h"

@interface TableCellFactory ()
+ (TableCellFactory *) Instance;
+ (UITableViewCell *) newCellWithName: (NSString *)cellName;
@end

@implementation TableCellFactory

@synthesize editableTextCell;
@synthesize editableTextAndUnitsCell;
@synthesize mashStepCell;

+ (TableCellFactory *) Instance {
	static TableCellFactory *sInstance = nil;
	if (sInstance == nil)
	{
		sInstance = [[TableCellFactory alloc] init];
	}
	return sInstance;
}

- (void) dealloc
{
	[editableTextCell release];	
	[editableTextAndUnitsCell release];
	[mashStepCell release];
	[super dealloc];
}

+ (UITableViewCell *) newCellWithName: (NSString *)cellName {
	TableCellFactory *factory = TableCellFactory.Instance;
	UITableViewCell *result = (UITableViewCell *)[factory valueForKey: cellName];
	
	if (result == nil) {		
		[[NSBundle mainBundle] loadNibNamed:@"TableViewCells" owner:factory options:nil];
		result = (UITableViewCell *)[factory valueForKey: cellName];
	}
	
	[[result retain] autorelease];
	[factory setValue:nil forKey:cellName];
	
	return result;
}

+ (EditableTextCell *) newEditableTextCell {
	return (EditableTextCell *)[TableCellFactory newCellWithName: @"editableTextCell"];
}

+ (EditableTextAndUnitsCell *) newEditableTextAndUnitsCell {
	return (EditableTextAndUnitsCell *)[TableCellFactory newCellWithName: @"editableTextAndUnitsCell"];
}

+ (MashStepCell *) newMashStepCell {
	return (MashStepCell *)[TableCellFactory newCellWithName: @"mashStepCell"];
}


@end
