//
//  CALayer+PauseAimate.m
//  QQ音乐
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 xiaomage. All rights reserved.
//

#import "CALayer+PauseAimate.h"

@implementation CALayer (PauseAimate)

- (void)pauseAnimate
{
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.0;//当前层的速度为0，暂停动画
    self.timeOffset = pausedTime; //层的停止时间设为上面申明的暂停时间
}

- (void)resumeAnimate
{
    CFTimeInterval pausedTime = [self timeOffset];// 当前层的暂停时间
     /** 层动画时间的初始化值 **/
    self.speed = 1.0;
    self.timeOffset = 0.0;
    self.beginTime = 0.0;
    /*--end--*/
    CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    //计算从哪里开始恢复动画
    self.beginTime = timeSincePause; //让层的动画从停止的位置恢复动效
}

@end
