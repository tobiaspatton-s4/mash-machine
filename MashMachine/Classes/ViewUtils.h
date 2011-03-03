//
//  ViewUtils.h
//  MashMachine
//
//  Created by Tobias Patton on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ViewUtils : NSObject {

}

+ (UIView* ) superViewOfView: (UIView *)view withClass: (Class)class;

@end
