//
//  ViewUtils.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-02.
//  Copyright 2011 Blue Cedar Creative Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ViewUtils : NSObject {

}

+ (UIView* ) superViewOfView: (UIView *)view withClass: (Class)class;

@end
