//
//  UIView+GradientLayer.m
//  paopaoread
//
//  Created by 七七 on 2019/3/27.
//  Copyright © 2019年 paopao. All rights reserved.
//

#import "UIView+GradientLayer.h"

@implementation UIView (GradientLayer)

-(CAGradientLayer *)simpleGradientFrom:(CGPoint)startP to:(CGPoint)endP WithColors:(NSArray<UIColor *> *)colors andLocations:(NSArray<NSNumber *> *)locations{
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *tmpButton=(UIButton *)self;
        [tmpButton.titleLabel removeFromSuperview];
        [self resetButtonGradientBackColor];
    }
    else
        [self resetGradientBackColor];
    
    CAGradientLayer *colorLayer = [CAGradientLayer layer];
    colorLayer.frame=self.bounds;
    [self.layer addSublayer:colorLayer];
    
    // 颜色分配
    NSMutableArray *tmpMutiArr=[NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<[colors count]; i++) {
        [tmpMutiArr addObject:(__bridge id)[(UIColor*)colors[i] CGColor]];
    }
    colorLayer.colors=[NSArray arrayWithArray:tmpMutiArr];
//    colorLayer.colors = @[(__bridge id)[UIColor redColor].CGColor,
//                          (__bridge id)[UIColor greenColor].CGColor,
//                          (__bridge id)[UIColor blueColor].CGColor];
    
    // 颜色分割线
    colorLayer.locations=[NSArray arrayWithArray:locations];
//    colorLayer.locations  = @[@(0.25), @(0.5), @(0.75)]; //NSNumber *
    
    // 起始点
    colorLayer.startPoint =startP;// CGPointMake(0, 0); //0,0表示左上角，1,1表示右下角
    
    // 结束点
    colorLayer.endPoint= endP;// CGPointMake(1, 0);
    
//    颜色分配严格遵守Layer的坐标系统,locations,startPoint,endPoint都是以Layer坐标系统进行计算的.
//    而locations并不是表示颜色值所在位置,它表示的是颜色在Layer坐标系相对位置处要开始进行渐变颜色了.
    
//    colorLayer.mask = circle; //可以利用layer.mask将渐变色附加到指定图形中
    
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *tmpButton=(UIButton *)self;
        [tmpButton addSubview:tmpButton.titleLabel];
    }
    //如果有对titleLabel的设置，且button设置了渐变，则所有titleLabel的设置必须在渐变之后，否则titielabel不会显示
    //设置过渐变的Button，需要“重新”设置TitleLabel时，需先将titleLabel移去掉,
    
    return colorLayer;
}

-(void)viewWithDefaultGradientColor{
    [self simpleGradientFrom:CGPointMake(0.12, 0) to:CGPointMake(1, 1) WithColors:@[[UIColor colorWithRed:235/255.0 green:119/255.0 blue:41/255.0 alpha:1.0],[UIColor colorWithRed:236/255.0 green:37/255.0 blue:85/255.0 alpha:1.0]] andLocations:@[@(0), @(1.0f)]];
}



/**
    去掉渐变背景
 */
-(void)resetGradientBackColor{
    for (id perLayer in [self.layer sublayers]) {
        if ([perLayer isKindOfClass:[CAGradientLayer class]]) {
            [(CAGradientLayer *)perLayer removeFromSuperlayer];
            break;
        }
    }
}

-(void)resetButtonGradientBackColor{
    if (![self isKindOfClass:[UIButton class]]) {
        return;
    }
    
    UIButton *tmpButton=(UIButton *)self;
    for (id perLayer in [self.layer sublayers]) {
        if ([perLayer isKindOfClass:[CAGradientLayer class]]) {
            [(CAGradientLayer *)perLayer removeFromSuperlayer];
            [tmpButton.titleLabel removeFromSuperview];
            break;
        }
    }
    
    if (![tmpButton.titleLabel superview]) {
        [tmpButton addSubview:tmpButton.titleLabel];
    }
    
}


-(void)changeButtonGradientColor:(NSInteger)colorType withTitleInfo:(NSDictionary *)titleInfo{
    if (![self isKindOfClass:[UIButton class]]) {
        return;
    }
    UIButton *tmpButton=(UIButton *)self;
    //先判断是否设置了渐变
    //如若设置了渐变，则先将渐变去掉，再重新设置color,及titleInfo
    [self resetButtonGradientBackColor];
    
    if (colorType==0) {//正常(红)
        [tmpButton simpleGradientFrom:CGPointMake(0, 0) to:CGPointMake(1, 1) WithColors:@[[UIColor colorWithRed:255/255.0 green:102/255.0 blue:0/255.0 alpha:1.0],[UIColor colorWithRed:255/255.0 green:0/255.0 blue:60/255.0 alpha:1.0]] andLocations:@[@(0), @(1.0f)]];
    }
    else if(colorType==1){//重置(半灰，与正常颜色一样，只不过透明度改成40%)
        [tmpButton simpleGradientFrom:CGPointMake(0, 0) to:CGPointMake(1, 1) WithColors:@[[UIColor colorWithRed:255/255.0 green:102/255.0 blue:0/255.0 alpha:0.4],[UIColor colorWithRed:255/255.0 green:0/255.0 blue:60/255.0 alpha:1.0]] andLocations:@[@(0), @(1.0f)]];
    }
    else if (colorType==2){//完成(黄)dailytaskArr[i]
        [tmpButton simpleGradientFrom:CGPointMake(1, 1) to:CGPointMake(0, 0) WithColors:@[[UIColor colorWithRed:255/255.0 green:141/255.0 blue:11/255.0 alpha:1.0],[UIColor colorWithRed:255/255.0 green:206/255.0 blue:0/255.0 alpha:1.0]] andLocations:@[@(0), @(1.0f)]];
    }
    else if(colorType==3){//不可用(全灰，与正常颜色一样，只不过透明度改成40%)
        [tmpButton simpleGradientFrom:CGPointMake(0, 0) to:CGPointMake(1, 1) WithColors:@[[UIColor colorWithRed:255/255.0 green:102/255.0 blue:0/255.0 alpha:0.4],[UIColor colorWithRed:255/255.0 green:0/255.0 blue:60/255.0 alpha:0.4]] andLocations:@[@(0), @(1.0f)]];
    }
    [tmpButton addSubview:tmpButton.titleLabel];

    if (![clsCommonFunc isValidateDict:titleInfo]) {
        return;
    }
    if([titleInfo objectForKey:@"title"]){
        [tmpButton setTitle:[titleInfo objectForKey:@"title"] forState:UIControlStateNormal];
    }
    if ([titleInfo objectForKey:@"titlecolor"]) {
        [tmpButton setTitleColor:[titleInfo objectForKey:@"titlecolor"] forState:UIControlStateNormal];
    }
    if ([titleInfo objectForKey:@"titlefont"]) {
        tmpButton.titleLabel.font=[titleInfo objectForKey:@"titlefont"];
    }
}

/**
 设置具有渐变背景的按钮信息

 @param color 为nil时表示默认渐变色(本工程中默认的统一的渐变背景色),否则为纯色背景
 @param titleInfo 包括title\titlecolor\titlefont
 */
-(void)changeButtonBackColor:(UIColor *)color withTitleInfo:(NSDictionary *)titleInfo{
    if (![self isKindOfClass:[UIButton class]]) {
        return;
    }
    UIButton *tmpButton=(UIButton *)self;
    //先判断是否设置了渐变
    //如若设置了渐变，则先将渐变去掉，再重新设置color,及titleInfo
    [self resetButtonGradientBackColor];
    
    if (color) {
        tmpButton.backgroundColor=color;
    }
    else{
        //暂定：所有按钮用统一风格的渐变
        if (tmpButton.isEnabled) {
            [tmpButton simpleGradientFrom:CGPointMake(0.12, 0) to:CGPointMake(1, 1) WithColors:@[[UIColor colorWithRed:255/255.0 green:102/255.0 blue:0/255.0 alpha:1.0],[UIColor colorWithRed:255/255.0 green:8/255.0 blue:56/255.0 alpha:1.0]] andLocations:@[@(0), @(1.0f)]];
        }
        else{
            [tmpButton simpleGradientFrom:CGPointMake(0, 0) to:CGPointMake(1, 1) WithColors:@[[UIColor colorWithRed:255/255.0 green:102/255.0 blue:0/255.0 alpha:0.4],[UIColor colorWithRed:255/255.0 green:0/255.0 blue:60/255.0 alpha:0.4]] andLocations:@[@(0), @(1.0f)]];
        }
        [tmpButton addSubview:tmpButton.titleLabel];
    }
 
    
    if (![clsCommonFunc isValidateDict:titleInfo]) {
        return;
    }
    if([titleInfo objectForKey:@"title"]){
        [tmpButton setTitle:[titleInfo objectForKey:@"title"] forState:UIControlStateNormal];
    }
    if ([titleInfo objectForKey:@"titlecolor"]) {
        [tmpButton setTitleColor:[titleInfo objectForKey:@"titlecolor"] forState:UIControlStateNormal];
    }
    if ([titleInfo objectForKey:@"titlefont"]) {
        tmpButton.titleLabel.font=[titleInfo objectForKey:@"titlefont"];
    }
}

-(void)buttonWithDefaultGradientColorAndTitle:(NSString *)title andfont:(UIFont *)font andTitleColor:(UIColor *)txtColor andBackcolor:(UIColor *)backColor{
    if (![self isKindOfClass:[UIButton class]]) {
        return;
    }
    UIButton *tmpButton=(UIButton *)self;
    //先判断是否设置了渐变
    //如若设置了渐变，则先将渐变去掉，再重新设置color,及titleInfo
    [self resetButtonGradientBackColor];
    
    if (backColor) {
        tmpButton.backgroundColor=backColor;
    }
    else{
       
        //暂定：所有按钮用统一风格的渐变
        if (tmpButton.isEnabled) {
            [tmpButton simpleGradientFrom:CGPointMake(0.12, 0) to:CGPointMake(1, 1) WithColors:@[[UIColor colorWithRed:235/255.0 green:119/255.0 blue:41/255.0 alpha:1.0],[UIColor colorWithRed:236/255.0 green:37/255.0 blue:85/255.0 alpha:1.0]] andLocations:@[@(0), @(1.0f)]];
        }
        else{
            [tmpButton simpleGradientFrom:CGPointMake(0, 0) to:CGPointMake(1, 1) WithColors:@[[UIColor colorWithRed:255/255.0 green:102/255.0 blue:0/255.0 alpha:1.0],[UIColor colorWithRed:255/255.0 green:0/255.0 blue:60/255.0 alpha:1.0]] andLocations:@[@(0), @(1.0f)]];
        }
        
    }
    
  
    [tmpButton setTitle:title forState:UIControlStateNormal];
 
    if (txtColor) {
        [tmpButton setTitleColor:txtColor forState:UIControlStateNormal];
    }
    if (font) {
        tmpButton.titleLabel.font=font;
    }
}

-(void)viewWithVideoTitleBack{
    //渐变色
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    [self.layer addSublayer:gradientLayer];
    gradientLayer.colors=@[(__bridge id)[_color_Black colorWithAlphaComponent:0.5].CGColor,(__bridge id)[_color_Black colorWithAlphaComponent:0.0].CGColor];
    gradientLayer.startPoint = CGPointMake(0.5, 0.0);//x=0.5,表示screen_w/2 y=0表示顶部0
    gradientLayer.endPoint = CGPointMake(0.5, 1.0);
}

@end
