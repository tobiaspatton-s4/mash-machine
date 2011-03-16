//
//  MashPlotCell.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-14.
//  Copyright 2011 Blue Cedar Creative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMashInfo.h"

@interface MashPlotCell : UITableViewCell <CPPlotDataSource> {
	id<IMashInfo> mashInfo;
	CPGraphHostingView *hostView;
	NSArray *allPlotData;
}

@property (nonatomic, assign) id<IMashInfo> mashInfo;
@property (nonatomic, retain) CPGraphHostingView *hostView;
@property (nonatomic, retain) NSArray *allPlotData;

@end
