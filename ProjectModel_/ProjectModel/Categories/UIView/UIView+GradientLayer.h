//
//  UIView+GradientLayer.h
//  paopaoread
//
//  Created by 七七 on 2019/3/27.
//  Copyright © 2019年 paopao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GradientLayer)
-(void)resetGradientBackColor;
-(CAGradientLayer *)simpleGradientFrom:(CGPoint)startP to:(CGPoint)endP WithColors:(NSArray<UIColor *> *)colors andLocations:(NSArray<NSNumber *> *)locations;
-(void)resetButtonGradientBackColor;
-(void)changeButtonBackColor:(UIColor * _Nullable)color withTitleInfo:(NSDictionary *)titleInfo;
-(void)buttonWithDefaultGradientColorAndTitle:(NSString *)title andfont:(UIFont *)font andTitleColor:(UIColor *)txtColor andBackcolor:(UIColor * _Nullable)backColor;

-(void)viewWithDefaultGradientColor;

-(void)changeButtonGradientColor:(NSInteger)colorType withTitleInfo:(NSDictionary *)titleInfo;
-(void)viewWithVideoTitleBack;
@end

NS_ASSUME_NONNULL_END
