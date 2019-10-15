//
//  ToastMessageTool.h
//  ProjectModel
//
//  Created by 黄龙 on 2019/10/14.
//  Copyright © 2019年 adong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToastMessageTool : NSObject
+ (void)showToastNotification:(NSString *)text withTextColor:(UIColor *_Nullable)txtColor andView:(UIView *_Nullable)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom andDelay:(float)delaySecond;
@end

NS_ASSUME_NONNULL_END
