//
//  ToastMessageTool.m
//  ProjectModel
//
//  Created by 黄龙 on 2019/10/14.
//  Copyright © 2019年 adong. All rights reserved.
//

#import "ToastMessageTool.h"
#import "GCDiscreetNotificationView.h"

@implementation ToastMessageTool

//无交互、自消失的Toast-Message提示
+ (void)showToastNotification:(NSString *)text withTextColor:(UIColor *)txtColor andView:(UIView *)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom andDelay:(float)delaySecond{
    if (isBottom) {
        GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc]initWithBotomText:text andColor:txtColor showActivity:isLoading inView:view];
        [notificationView show:YES];
        if (!delaySecond) {
            delaySecond=1.5f;
        }
        [notificationView hideAnimatedAfter:delaySecond];
    }
    else{
        GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc]initWithTopText:text andColor:txtColor showActivity:isLoading inView:view];
        [notificationView show:YES];
        if (!delaySecond) {
            delaySecond=1.5f;
        }
        [notificationView hideAnimatedAfter:delaySecond];
    }
}
//

@end
