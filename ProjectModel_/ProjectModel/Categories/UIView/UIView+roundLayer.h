//
//  UIView+roundLayer.h
//  paopaoread
//
//  Created by 七七 on 2018/12/11.
//  Copyright © 2018年 paopao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (roundLayer)
-(void)roundCorner:(CGFloat)iRadius;
-(void)roundCornerWithCornerRadii:(CGSize)cornerRadii andCorners:(UIRectCorner)corners;
-(void)roundCornerWithCornerRadii:(CGSize)cornerRadii andCorners:(UIRectCorner)corners andBordWidth:(CGFloat)bdWidth andBordColor:(UIColor *)bdColor;

-(void)roundCornerWithCornerRadii:(CGSize)cornerRadii andCorners:(UIRectCorner)corners withShadowInfo:(NSDictionary *)shadowInfo;
@end
