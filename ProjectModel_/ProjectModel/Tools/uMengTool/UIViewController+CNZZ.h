//
//  UIViewController+CNZZ.h
//  paopaoread
//
//  Created by 七七 on 2018/11/19.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CNZZ)
- (void)swizzled_viewDidAppear:(BOOL)animated;
- (void)swizzled_viewDidDisappear:(BOOL)animated;
@end
