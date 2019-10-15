//
//  UIView+roundLayer.m
//  paopaoread
//
//  Created by 七七 on 2018/12/11.
//  Copyright © 2018年 paopao. All rights reserved.
//

#import "UIView+roundLayer.h"

@implementation UIView (roundLayer)
-(void)roundCorner:(CGFloat)iRadius{
    if (iRadius>0) {
        self.layer.cornerRadius=iRadius; //此种方式影响渲染性能
        self.clipsToBounds=YES;
        self.layer.masksToBounds = YES;
//        clipsToBounds(UIView)是指视图上的子视图,如果超出父视图的部分就截取掉
//    masksToBounds(CALayer)却是指视图的图层上的子图层,如果超出父图层的部分就截取掉
    }
}


/**
优化渲染性能的圆角绘制方法
 */
-(void)roundCornerWithCornerRadii:(CGSize)cornerRadii andCorners:(UIRectCorner)corners{
    //*roundCornerWithCornerRadii要求frame先确定
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii: cornerRadii].CGPath;
    self.layer.mask = maskLayer;
    
}

-(void)roundCornerWithCornerRadii:(CGSize)cornerRadii andCorners:(UIRectCorner)corners andBordWidth:(CGFloat)bdWidth andBordColor:(UIColor *)bdColor{
    
    UIBezierPath *maskPath=[UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii: cornerRadii];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;

    //如果有边框，此时边框不能用self.layer.border来设置会有出入，而应该：
    if (bdWidth && bdColor) {
        //重复执行roundCornerWithCornerRadii，如果有border的话，会导致boder重叠错位,故添加boder前先清除之前的添加的
        for (CAShapeLayer *borderLayer in [self.layer sublayers]) {
            if ([borderLayer isKindOfClass:[CAShapeLayer class]]) {
                [borderLayer removeFromSuperlayer];
                break;
            }
        }
        CAShapeLayer *borderLayer=[CAShapeLayer layer];
        borderLayer.path= maskPath.CGPath;
        borderLayer.fillColor= [UIColor clearColor].CGColor;
        borderLayer.strokeColor= [bdColor CGColor];
        borderLayer.lineWidth= bdWidth;
        borderLayer.frame=self.bounds;
        [self.layer addSublayer:borderLayer];
        
    }
    
}

-(void)roundCornerWithCornerRadii:(CGSize)cornerRadii andCorners:(UIRectCorner)corners withShadowInfo:(NSDictionary *)shadowInfo{
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *maskPath= [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii: cornerRadii];
//    maskLayer.path =maskPath.CGPath;
//    //    self.layer.mask = maskLayer;
//
    ((CAShapeLayer *)self.layer).path = maskPath.CGPath;
    self.layer.shadowPath=maskPath.CGPath;
    if ([clsCommonFunc isValidateDict:shadowInfo]) {
        UIColor *color=[shadowInfo objectForKey:@"color"];
        if(color)
            self.layer.shadowColor=color.CGColor;
        NSNumber *radius=[shadowInfo objectForKey:@"radius"];
        if(radius)
            self.layer.shadowRadius=[radius floatValue];
        NSNumber *offset=[shadowInfo objectForKey:@"offset"];
        if (offset)
            self.layer.shadowOffset=[offset CGSizeValue];
        NSNumber *opacity=[shadowInfo objectForKey:@"opacity"];
        if (opacity)
            self.layer.shadowOpacity=[opacity floatValue];
    }

}

@end
