//
//  MBProgressHUD+KD.m
//  paopaoread
//
//  Created by 七七 on 2018/6/14.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#import "MBProgressHUD+KD.h"

@implementation MBProgressHUD (KD)

 /*---显示延时自动消失的自定义图标及文字
文本信息：textInfo[text,font,color]
delayTime:(s)后自动消失，必须设置自动消失操作
----*/
+ (void)show:(NSDictionary *)textInfo withIcon:(UIImage *)iconImage afterDelay:(CGFloat)delayTime toView:(UIView *)view
{
//    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(195 / 2, 200, 170,170)];
//    bgView.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:bgView];
//    bgView.userInteractionEnabled = NO;
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:bgView animated:YES];
// 在HUD下自定义一个父视图，把HUD加到自己定义的View上，这样可以控制MBProgressHUD大小，如：需要文本换行的情况下，可以初始view的大小来达到换行的目的

    if (view == nil)
        view = [[UIApplication sharedApplication] keyWindow];//[[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.bezelView.style = MBProgressHUDBackgroundStyleBlur;
    if (textInfo) {
        NSString *sText=[textInfo objectForKey:@"text"];
        if (![clsCommonFunc isEmptyStr:sText]) {
            hud.label.text = sText;
        }
        NSString *detail=[textInfo objectForKey:@"detail"];
        if (![clsCommonFunc isEmptyStr:detail]) {
            hud.detailsLabel.text = detail;
        }
        UIFont *textfont=[textInfo objectForKey:@"textfont"];
        if (textfont) {
            hud.label.font =textfont;// [UIFont systemFontOfSize:17.0];
        }
        UIColor *textcolor=[textInfo objectForKey:@"textcolor"];
        if (textcolor) {
//            hud.label.textColor =textcolor;// Color333333;
            hud.contentColor=textcolor; //现有模式下只能改所有的文本代码，要区别的话，需将原码的contentColor，改成NSArray类型
        }
    
        
        UIFont *detailfont=[textInfo objectForKey:@"detailfont"];
        if (detailfont) {
            hud.detailsLabel.font =detailfont;// [UIFont systemFontOfSize:17.0];
        }
//        UIColor *detailcolor=[textInfo objectForKey:@"detailcolor"];
//        if (detailcolor) {
//            hud.detailsLabel.textColor =detailcolor;// Color333333;
//        }
        
        UIColor *backColor=[textInfo objectForKey:@"backcolor"];
        if(backColor){
            hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
            hud.bezelView.backgroundColor =backColor;// mainGrayColor;    //背景颜色
        }
    }
    
//    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;//如果想要自定义背景，需设置bezelView为MBProgressHUDBackgroundStyleSolidColor，然后用自定义的颜色和透明度来设置
    
    hud.userInteractionEnabled= NO;
    if (iconImage) {
        hud.customView= [[UIImageView alloc]initWithImage:iconImage];// 设置图片
    }
    
    
    // 设置图片
//    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    
    // 再设置模式为自定义模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // delayTime秒之后再消失
    [hud hideAnimated:YES afterDelay:delayTime];
}

//只显示图标
+ (void)showImage:(UIImage *)iconImage{
    [self showImage:iconImage withMsg:nil toView:nil];
}

//只显示文字
+ (void)showMessage:(NSString *)msg andDetail:(NSString *)detailText{
    [self showMessage:msg andDetail:detailText toView:nil];
}

//只显示文字
+ (void)showMessage:(NSString *)msg andDetail:(NSString *)detailText toView:(UIView *)view{
    if (view == nil)
        view = [[UIApplication sharedApplication] keyWindow];//[[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    //只有文字
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(msg, @"HUD message title");
    if (![clsCommonFunc isEmptyStr:detailText]) {
        hud.detailsLabel.text=detailText;
    }
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // delayTime秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}

//显示图标和文字
+ (void)showImage:(UIImage *)iconImage withMsg:(NSString *)msg{
    [self showImage:iconImage withMsg:msg toView:nil];
}

//在指定View上显示图标和文字
+ (void)showImage:(UIImage *)iconImage withMsg:(NSString *)msg toView:(UIView *)view{
    NSDictionary *dict=nil;
    if (![clsCommonFunc isEmptyStr:msg]) {
        dict=[NSDictionary dictionaryWithObjectsAndKeys:msg,@"text", nil];
    }
    [self show:dict withIcon:iconImage afterDelay:1.5 toView:view];
}

//显示图标和文字
+ (void)showImage:(UIImage *)iconImage withMsg:(NSString *)msg andDetail:(NSString *)detailText{
    [self showImage:iconImage withMsg:msg andDetail:detailText toView:nil];
}
//在指定View上显示图标和文字
+ (void)showImage:(UIImage *)iconImage withMsg:(NSString *)msg andDetail:(NSString *)detailText toView:(UIView *)view{
    NSDictionary *dict=nil;
    if (![clsCommonFunc isEmptyStr:msg]) {
        dict=[NSDictionary dictionaryWithObjectsAndKeys:msg,@"text",detailText,@"detail", nil];
    }
    [self show:dict withIcon:iconImage afterDelay:1.5 toView:view];
}

+ (void)showImage:(UIImage *)iconImage withMsgInfo:(NSDictionary *)msgInfo andDelay:(CGFloat)iTime toView:(UIView *)view{
    [self show:msgInfo withIcon:iconImage afterDelay:iTime toView:view];
}

//加载动画
+(void)showLoadingwithMsg:(NSString *)msg andbackColor:(UIColor *)color andTitleColor:(UIColor *)titleColor toView:(UIView *)view{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    if (view == nil){
        view = [[UIApplication sharedApplication] keyWindow];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if([clsCommonFunc isEmptyStr:msg]){
        msg=@"加载中...";
    }
    //     小菊花+文字，自动循环，无需控制进度
    hud.label.text=NSLocalizedString(msg, @"HUD loading title");
    //6，设置菊花颜色  只能设置菊花的颜色
    //    hud.activityIndicatorColor = [UIColor blackColor];
    hud.detailsLabel.text = @"请稍候";
    hud.minSize = CGSizeMake(Screen_W/2, 150.f);
    //    hud.removeFromSuperViewOnHide=NO;
    //2,设置背景框的背景颜色和透明度， 设置背景颜色之后opacity属性的设置将会失效
    if (color) {
        //        hud.color =color;
        //    hud.color = [hud.color colorWithAlphaComponent:0.5];//colorWithAlphaComponent：设置背景颜色透明度,也可以保证子控件不透明
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.backgroundColor =color;// mainGrayColor;    //背景颜色
    }
    if (titleColor) {
        hud.contentColor=titleColor;
    }
}

//自消失的加载动画
//+(void)showLoading:(NSUInteger)iType withMsg:(NSString *)msg toView:(UIView *)view{
////    dispatch_async(dispatch_get_main_queue(), ^{
//        if (view == nil)
//            view = [[UIApplication sharedApplication].windows lastObject];
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//        if([clsCommonFunc isEmptyStr:msg]){
//            msg=@"加载中";
//        }
//    switch (iType) {
//        case 0:
//            //     小菊花+文字，自动循环，无需控制进度
//            hud.label.text=NSLocalizedString(msg, @"HUD loading title");
//            break;
//        case 1:{//     圆环进度条+文字,需自定义控制进度
//            hud.mode = MBProgressHUDModeDeterminate;
//            hud.label.text = NSLocalizedString(msg, @"HUD loading title");
////            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
////                // Do something useful in the background and update the HUD periodically.
////                [self doSomeWorkWithProgress];
////                dispatch_async(dispatch_get_main_queue(), ^{
////                    [hud hideAnimated:YES];
////                });
////            });
////            or:
//            [hud showAnimated:YES whileExecutingBlock:^{
//                float progress = 0.0f;
//                while (progress < 1.0f) {
//                    progress += 0.01f;
//                    hud.progress = progress;
//                    usleep(50000);
//                }
//            } completionBlock:^{
//                [hud removeFromSuperview];
////                [hud release];
////                hud = nil;
//            }];
//        }
//            break;
//        case 2:{
//            //     直线进度条+文字,需自定义控制进度
//            hud.mode = MBProgressHUDModeAnnularDeterminate;
//            hud.label.text = NSLocalizedString(msg, @"HUD loading title");
//        }
//        case 3:{
//            //      直线进度条+文字,需自定义控制进度
//            hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
//            hud.label.text = NSLocalizedString(msg, @"HUD loading title");
//        }
//            break;
//        default:
//            //     小菊花+文字:
//            hud.label.text=NSLocalizedString(msg, @"HUD loading title");
//            break;
//    }
//    hud.detailsLabelText = @"请稍候...";
//    [hud hideAnimated:YES afterDelay:5.5];
//
////    hud.minSize = CGSizeMake(100.f, 50.f);
//}


+ (void)hideHUD{
    [self hideHUDForView:nil];
}

+ (void)hideHUDForView:(UIView *)view{
    if (view == nil)
        view = [[UIApplication sharedApplication] keyWindow];//[[UIApplication sharedApplication].windows lastObject];
    
    [self hideHUDForView:view animated:YES];
}


+(void)showOrHideLoading:(BOOL)show withMsg:(NSString *_Nullable)msg inView:(UIView *_Nullable)superView withBlackBkColor:(BOOL)black{
    if(show){
        if (black) {
            [MBProgressHUD showLoadingwithMsg:msg andbackColor:[_color_Black colorWithAlphaComponent:0.85] andTitleColor:_color_White toView:superView];
        }
        else
            [MBProgressHUD showLoadingwithMsg:msg andbackColor:nil andTitleColor:nil toView:superView];
    }
    else{
        [MBProgressHUD hideHUDForView:superView];
    }
}

@end
