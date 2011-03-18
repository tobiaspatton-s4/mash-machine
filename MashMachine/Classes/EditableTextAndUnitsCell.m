//
//  EditableTextAndUnitsCell.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-04.
//  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
//

#import "EditableTextAndUnitsCell.h"

enum {
	kTagUnitsLabel = 3
};

@implementation EditableTextAndUnitsCell

- (UILabel *) unitsLabel {
	return (UILabel *)[self viewWithTag:kTagUnitsLabel];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
