//
//  MashProfileCell.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MashProfileCell.h"

enum {
	kTagTextField = 1,
	kTagDetailLabel = 2
};

@implementation MashProfileCell

@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (UITextField *) textField {
	return (UITextField *)[self viewWithTag:kTagTextField];	
}

- (UILabel *) detailTextLabel {
	UILabel *result = (UILabel *)[self viewWithTag:kTagDetailLabel];	
	return result;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void) setEditing:(BOOL)value animated:(BOOL)animated{
	[super setEditing:value animated:animated];
	self.textField.textColor = value ? [UIColor blueColor] : [UIColor darkGrayColor];
	self.textField.userInteractionEnabled = value;
}

- (void)dealloc {
    [super dealloc];
}


@end
