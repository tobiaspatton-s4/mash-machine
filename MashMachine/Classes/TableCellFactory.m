//
//  TableCellFactory.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TableCellFactory.h"
#import "MashStepCell.h"

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

+ (UITableViewCell *) newEditableTextCell {
	return [TableCellFactory newCellWithName: @"editableTextCell"];
}

+ (UITableViewCell *) newEditableTextAndUnitsCell {
	return [TableCellFactory newCellWithName: @"editableTextAndUnitsCell"];
}

+ (MashStepCell *) newMashStepCell {
	return (MashStepCell *)[TableCellFactory newCellWithName: @"mashStepCell"];
}


@end
