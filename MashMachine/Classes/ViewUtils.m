//
//  ViewUtils.m
//  MashMachine
//
//  Created by Tobias Patton on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewUtils.h"


@implementation ViewUtils

+ (UIView* ) superViewOfView: (UIView *)view withClass: (Class)class {
	if (view == nil)
	{		
		return nil;
	}
	
	if ([view.superview isKindOfClass:class]) {
		return view.superview;
	}
	
	return [ViewUtils superViewOfView:view.superview withClass:class];
}

@end
