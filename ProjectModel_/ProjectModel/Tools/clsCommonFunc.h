//
//  paopaoread
//
//  Created by xiaoQing on 2017/12/20.
//  Copyright © 2017年 xiaoqing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NSAimateType) {
    animate_Fade     = 0,//交叉淡化过渡,可以设置方向，但animate为NO时没什么效果，为YES时才有方向交叉切换效果
    animate_Push_L      = 1,//新视图将旧视图推出去
    animate_Push_R    = 2,
    animate_Push_T     = 3,
    animate_Push_B     = 4,
    animate_MoveIN_L      = 5,//移动覆盖原图
    animate_MoveIN_R    = 6,
    animate_MoveIN_T     = 7,
    animate_MoveIN_B     = 8,
    animate_Reveal_L      = 9,//移掉旧视图显示底部新视图出来
    animate_Reveal_R    = 10,
    animate_Reveal_T     = 11,
    animate_Reveal_B     = 12,
    animate_Flip     = 13,//oglFlip 上下翻转效果
    
    animate_Cube_L     = 14,//立方体效果,立方体翻滚效果
    animate_Cube_R     = 15,
    animate_Cube_T     = 16,
    animate_Cube_B     = 17,
    
    animate_PageCurl_L     = 18,//向上翻一页
    animate_PageCurl_R     = 19,
    animate_PageCurl_T     = 20,
    animate_PageCurl_B     = 21,
    
    animate_PageUncurl_L     = 22,//向下翻一页
    animate_PageUncurl_R     = 23,
    animate_PageUncurl_T     = 24,
    animate_PageUncurl_B     = 25,
    
    animate_RippleEffect    = 26,//滴水效果
    animate_SuckEffect     = 27,//收缩效果，如一块布被抽走
    animate_cameraIrisHollowOpen=28,  //相机镜头打开效果(不支持过渡方向)
    animate_cameraIrisHollowClose=29 //相机镜头关上效果(不支持过渡方向)
    
    
};


@interface clsCommonFunc : NSObject

//NS_ASSUME_NONNULL_BEGIN
//所有简单指针对象都被假定为nonnull
+ (UIColor *)colorWithHex:(NSString*)hexValue alpha:(CGFloat)alphaValue;
+ (UIColor *)colorWithHexString:(NSString *)hexValue;


//初化创建label
+(UILabel *)initALabel:(NSString *_Nullable)text textfont:(UIFont *_Nullable)font textColor:(UIColor*_Nullable)color textAlign:(NSTextAlignment)alignment;
+(UILabel *)initALabel:(NSString *_Nullable)text textfont:(UIFont *_Nullable)font textColor:(UIColor*_Nullable)color textAlign:(NSTextAlignment)alignment
             andTarget:(id)target andAction:(SEL)action;
//初始化创建图片按钮
+(UIButton *)initAButtonWithImage:(UIImage *)btnImg andTarget:(id)target andAction:(SEL)action;
+(UIButton *)initAButtonWithBackImage:(UIImage *)btnImg andTarget:(id)target andAction:(SEL)action;
+(UIButton *)initAButtonWithTitle:(NSString *)title andBorderColor:(UIColor *_Nullable)color andCorner:(CGFloat)cornerRadius andTarget:(id)target andAction:(SEL)action;
+(UIButton *)initAButtonWithFrame:(CGRect)frame andBorderColor:(UIColor *)color andCorner:(CGFloat)cornerRadius andTarget:(id)target andAction:(SEL)action;
//初化带tap的uiimageView
+(UIImageView *)initAImageViewWithImage:(UIImage *)image andTarget:(id)target andAction:(SEL)action;


+(NSArray * _Nullable)separatedString:(NSString *)str ByString:(NSString *)split;
+(NSString *)formatNowTime:(NSString *)dateFormat;
+(NSString *)formatDateTime:(NSDate *)theDate withFormat:(NSString *)dateFormat;
+(NSString *)formatLocalDateTime:(NSDate *)localDate withFormat:(NSString *)dateFormat;
+(NSDate *)getLocalNowDate;
+(NSDate *)getLocalNowDateTime;
+(NSDate *)getLocalDateFromGMTDate:(NSDate *)theNsdate;
+(NSDate *)getGMTDateFromLoaclDate:(NSDate *)localDate;
+(NSDate *)getOtherDateThenDate:(NSDate *)nowDate offset:(CGFloat)iDay;
+ (NSInteger)numberOfDaysFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

+(void)PushDetailViewControll:(UIViewController *)detailVC byNaviController:(UINavigationController *)naviVC andHide:(BOOL)hideFlag;
+(void)animatePushDetailViewControll:(UIViewController *)detailVC byNaviController:(UINavigationController *)naviVC  andHide:(BOOL)hideFlag withAnimate:(NSAimateType)iAnimate;
+(void)randAnimatePushDetailViewControll:(UIViewController *)detailVC byNaviController:(UINavigationController *)naviVC andHide:(BOOL)hideFlag;
+(NSString *)getRandomStringWithLength:(NSInteger)iLen;
+(NSString *)replaceUnicode:(NSString *)unicodeStr;

+(void)copyWordsToPasteboard:(NSString *)keyWord;
+(id _Nullable)readDatasFromJsonFile:(NSString *)sfileName ifUtf8:(BOOL)utf8Flag;
+(void)async2mainQueueWithUIPro:(dispatch_block_t)uiProblock;
+(void)async2GlobalQueueWithUIPro:(dispatch_block_t)htProblock;
+(void)popNaviController:(UINavigationController *)navigationController animate:(BOOL)flag;

+(NSDictionary *)theNLInfoOfDay:(NSDate *)aDay;
+(NSInteger)theWeakIndexOfDay:(NSDate *)aDay;
+(NSString *)getWeekStrByIndex:(NSInteger)iWeek andType:(BOOL)longtype;
+(NSDate *)strToDate:(NSString *)dateStr withFormat:(NSString *_Nullable)formatStr;
+(NSString *)theShengXiaoOfYear:(NSString *)year;

//NS_ASSUME_NONNULL_END

+ (NSTimeInterval)theMinisecondTimestamp;
+ (NSTimeInterval)theSecondTimestamp;
+(BOOL)isEmptyStr:(NSString *_Nullable)str;
+(BOOL)isHttpStr:(NSString *_Nullable)str;
+(BOOL)isPushOpened;
+(BOOL)isValidateDict:(id _Nullable)dict;
+(BOOL)isValidateArr:(id _Nullable)arr;
+(BOOL)isValidateData:(id _Nullable)data;
+(void)gotoAppConfigUI;

+(NSString *)confirmDictStringObject:(id)obj;
+(NSString *)confirmDictStringObject:(id)obj withDefaultValue:(NSString *)defValue;
/**
 截取源图的指定区域
 */
+(UIImage *)getAImageFromSourceImage:(UIImage *)sourceImg withRect:(CGRect)rect;


/**
 将原图指定区域进行tile填充，以放大原图
 */
+(UIImage *)enlargeSourceImage:(UIImage *)sourceImg withEdge:(UIEdgeInsets)edge;

/**
 获取本view所在的ViewController
 @return 宿主ViewController
 */
+(UIViewController *)viewControllerWithClass:(Class _Nullable)vcClass forView:(UIView *)view;


/**
 将一组数据随机排序
 */
+(NSArray *)randAListData:(NSArray *)listData;

+(UIImage *)fixImageOrientation:(UIImage *)aImage;



@end
