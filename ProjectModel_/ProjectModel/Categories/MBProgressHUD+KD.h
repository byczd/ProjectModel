//
//  MBProgressHUD+KD.h
//  paopaoread
//
//  Created by 七七 on 2018/6/14.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (KD)
//显示自消失的自定义图标和文字
+ (void)show:(NSDictionary *)textInfo withIcon:(UIImage *)iconImage afterDelay:(CGFloat)delayTime toView:(UIView *)view;
//只显示图标
+ (void)showImage:(UIImage *)iconImage;
//只显示文字
+ (void)showMessage:(NSString *)msg andDetail:(NSString *)detailText;
//只显示文字
+ (void)showMessage:(NSString *)msg andDetail:(NSString *)detailText toView:(UIView *)view;
//显示图标和文字
+ (void)showImage:(UIImage *)iconImage withMsg:(NSString *)msg;
//在指定View上显示图标和文字
+ (void)showImage:(UIImage *)iconImage withMsg:(NSString *)msg toView:(UIView *)view;

//显示图标和文字
+ (void)showImage:(UIImage *)iconImage withMsg:(NSString *)msg andDetail:(NSString *)detailText;
//在指定View上显示图标和文字
+ (void)showImage:(UIImage *)iconImage withMsg:(NSString *)msg andDetail:(NSString *)detailText toView:(UIView *)view;
//在指定View上显示图标和文字
+ (void)showImage:(UIImage *)iconImage withMsgInfo:(NSDictionary *)msgInfo andDelay:(CGFloat)iTime toView:(UIView *)view;
//自消失的加载动画
//+(void)showLoading:(NSUInteger)iType withMsg:(NSString *)msg toView:(UIView *)view;

//加载动画
+(void)showLoadingwithMsg:(NSString *)msg andbackColor:(UIColor *)color andTitleColor:(UIColor *)titleColor toView:(UIView *)view;


+ (void)hideHUD;
+ (void)hideHUDForView:(UIView *)view;

+(void)showOrHideLoading:(BOOL)show withMsg:(NSString *_Nullable)msg inView:(UIView *_Nullable)superView withBlackBkColor:(BOOL)black;
@end
