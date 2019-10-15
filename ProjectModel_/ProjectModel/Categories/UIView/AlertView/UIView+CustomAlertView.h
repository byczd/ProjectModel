//
//  UIView+CustomAlertView.h
//  CustomAnimation
//
//  Created by ning on 2017/4/17.
//  Copyright © 2018年 七七. All rights reserved.
// 只控制弹窗view的动画显示效果，具体弹窗View显示内容由外部处理

#import <UIKit/UIKit.h>
#define TagValue  3333
typedef NS_ENUM(NSInteger, JKCustomAnimationMode) {
    JKCustomAnimationModeAlert = 0,//弹出效果
    JKCustomAnimationModeDrop, //由上方掉落
    JKCustomAnimationModeShare,//下方弹出（类似分享效果）
    JKCustomAnimationModeNone,//没有动画
};

typedef void(^hideCompleteBlock)(void);

@interface UIView (CustomAlertView){
//    BOOL neddFlag;//不能添加成员变量
}
//类别可以为已有的类添加方法，但是却不能"直接"添加属性，因为即使你添加了@property，它既不会生成实例变量，也不会生成setter、getter方法，即使你添加了也无法使用
//@property(nonatomic,assign)BOOL needEffectView;//模糊背景
//@property(nonatomic,assign)CGFloat alphaBack;
//@property(nonatomic,assign)BOOL tapBackToRemove;//是否点击背景移去alert
//@property (nonatomic, strong) UIWindow *cover;
//@property (nonatomic, weak) UIView *coverView;

/**
 显示 弹出view 任意view导入头文件之后即可调用
 @param animationMode CustomAnimationMode 三种模式
 @param alpha CGFloat  背景透明度 0-1  默认0.2  传-1即为默认值
 @param isNeed BOOL 是否需要背景模糊效果
 */
-(void)jk_showInWindowWithMode:(JKCustomAnimationMode)animationMode inView:(UIView *)superV bgAlpha:(CGFloat)alpha needEffectView:(BOOL)isNeed needTapBkRemove:(BOOL)tapBkClose;

-(void)jk_showDelayWindowWithMode:(JKCustomAnimationMode)animationMode inView:(UIView *)superV bgAlpha:(CGFloat)alpha needEffectView:(BOOL)isNeed needTapBkRemove:(BOOL)tapBkClose autohideAfter:(CGFloat)delayTime;

/**
 隐藏 view
 */
-(void)jk_hideView;


/**
 给view 各个边加 layer.border
 */
- (void)jk_setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width;


/**
 add by adong

 @param Completehandler block when hide finish
 */
-(void)jk_hideViewWhenFinish:(hideCompleteBlock)Completehandler;

@end

