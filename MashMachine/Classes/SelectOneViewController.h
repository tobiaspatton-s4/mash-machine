//
//  SelectOneViewController.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectOneViewController;

@protocol SelectOneViewControllerDelegate

- (void) selectOneViewController: (SelectOneViewController *)controller didSelectOptionAtIndex: (int) index;

@end


@interface SelectOneViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	@private
	NSString *labelPath;
	NSArray *options;
	int selectedIndex;
	id<SelectOneViewControllerDelegate> delegate;
}

@property (nonatomic, copy) NSString *labelPath;
@property (nonatomic, retain) NSArray *options;
@property (assign) int selectedIndex;
@property (nonatomic, assign) id<SelectOneViewControllerDelegate> delegate;

@end
