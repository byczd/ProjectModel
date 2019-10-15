//
//  paopaoread
//
//  Created by xiaoQing on 2017/12/20.
//  Copyright © 2017年 xiaoqing. All rights reserved.
//

#import "clsCommonFunc.h"
#import "UIView+roundLayer.h"

@implementation clsCommonFunc

//16进制window颜色值转成ios颜色值
+ (UIColor*)colorWithHex:(NSString*)hexValue alpha:(CGFloat)alphaValue {
    if ([hexValue length] < 6)
        return _color_Clear;
    else if ([hexValue length]>6){
        if ([hexValue hasPrefix:@"0X"] || [hexValue hasPrefix:@"0x"])
            hexValue = [hexValue substringFromIndex:2];
        else if ([hexValue hasPrefix:@"#"])
            hexValue = [hexValue substringFromIndex:1];
        else if ([hexValue hasPrefix:@"$"])
            hexValue = [hexValue substringFromIndex:1];
    }
    if ([hexValue length] != 6)
        return _color_Clear;
    
    NSInteger red=strtoul([[hexValue substringWithRange:NSMakeRange(0, 2)] UTF8String], 0, 16);
    
    NSInteger green=strtoul([[hexValue substringWithRange:NSMakeRange(2, 2)] UTF8String], 0, 16);
    
    NSInteger blue=strtoul([[hexValue substringWithRange:NSMakeRange(4, 2)] UTF8String], 0, 16);
    
    return [UIColor colorWithRed:(float)red/255.0 green:(float)green/255.0 blue:(float)blue/255.0 alpha:alphaValue];
}

//16进制window颜色值转成ios颜色值
+ (UIColor *)colorWithHexString:(NSString *)hexValue
{
    return [self colorWithHex:hexValue alpha:1.0];
}

//获取当前时间
+ (NSTimeInterval)theMinisecondTimestamp
{
    //ios获取自1970年以来的毫秒数
    NSTimeInterval timestamp=[[NSDate date] timeIntervalSince1970]*1000;
    return timestamp;
}

+ (NSTimeInterval)theSecondTimestamp
{
    //ios获取自1970年以来的秒数
    NSTimeInterval timestamp=[[NSDate date] timeIntervalSince1970];
    return timestamp;
}

/**
 格式化本地时区的日期时间，NSDateFormatter会自动将GMT时间，故先将本地时区的日期时间，转化成GMT时间，然后再format
 */
+(NSString *)formatLocalDateTime:(NSDate *)localDate withFormat:(NSString *)dateFormat{
    NSDate *gmtDate=[self getGMTDateFromLoaclDate:localDate];
    return [self formatDateTime:gmtDate withFormat:dateFormat];
}

/**
 格式化GMT类型的日期时间
 */
+(NSString *)formatDateTime:(NSDate *)theDate withFormat:(NSString *)dateFormat{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];//@"yyyy-MM-dd HH:mm:ss"
    return [formatter stringFromDate:theDate];
    //但用NSDateFormatter会自动将GMT时间，转成本地时区时间(故不要传入本地时区的Date)
}

+(NSString *)formatNowTime:(NSString *)dateFormat{
    return  [self formatDateTime:[NSDate date] withFormat:dateFormat];
    //但用NSDateFormatter返回指定格式"yyyy-MM-dd HH:mm:ss"或“HH:mm:ss”等的时候，不需要+8小时，formatter stringFromDate会自动转换+8小时
    //所有直接用[NSDate date]即可，不需要用getLocalNowDateTime
    //但用NSDateFormatter会自动将GMT时间，转成本地时区时间，而[NSDate date]返回的即是GTM时间
}

/**
 将GMT日期，转成本地时区的日期
 切记：如果用YYYY-MM-dd则会发生2018-12-31 00:00:00 +0000会转成2019/12/31的情况
 必须用yyyy-MM-dd HH:mm:ss
 */
+(NSDate *)getLocalNowDate{
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];
    //yyyy-MM-dd HH:mm:ss这里去掉具体时间,保留日期2018-03-26
    //!!!!!!!!切记日期为yyyy-MM-dd，如果写成了YYYY-MM-dd,有些Date的日期转出来会发现年份增加了一年;如2018-12-30的变成了2019-12-30
    NSString * curDateStr = [formater stringFromDate:[NSDate date]];
    NSDate *theDate=[formater dateFromString:curDateStr];//如果直接转换的话，则打印theDate为2018-03-25 16:00:00 +0000，日期变了
    NSDate *theLocalDate=[self getLocalDateFromGMTDate:theDate];
    return theLocalDate;
    //返回NSDate类型的话，需要用getLocalDateFromGMTDate+8小时
}

/**
 将GMT日期时间，转成本地时区的日期时间
 */
+(NSDate *)getLocalNowDateTime{
    //获取日期+时分秒
//    NSDate存储的是世界标准时(UTC)，输出时需要根据时区转换为本地时间
    return  [self getLocalDateFromGMTDate:[NSDate date]];
}


+(NSDate *)getLocalDateFromGMTDate:(NSDate *)theNsdate{
    //    通过[NSDate date]可以获取系统日期时间，但时间是0时区的系统日期时间,与北京时间相差8个小时
    //需要时行转换,第一种方法：
    //    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateStyle:NSDateFormatterFullStyle];//NSDateFormatterFullStyle = kCFDateFormatterFullStyle
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSString *dateString = [dateFormatter stringFromDate:now];//这样才对是手机显示的当前时间
    //    NSDate *theDate=[dateFormatter dateFromString:dateString];
    //    return theDate;
    
    //第二种方法获取手机当前显示的时间
    NSTimeZone *zone = [NSTimeZone systemTimeZone];//sia/Shanghai (GMT+8) offset 28800
    NSInteger interval = [zone secondsFromGMTForDate:theNsdate];//相差的秒数，即个8个小时
    NSDate *localeDate = [theNsdate dateByAddingTimeInterval: interval];//加上8个小时,得到手机上当前显时的时间
    return localeDate;
}

/**
 将本时区的日期时间转成GMT日期时间
 有些功能如日历功能中的日期时间，需要用GMT时间
 */
+(NSDate *)getGMTDateFromLoaclDate:(NSDate *)localDate{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:localDate];
    NSDate *gmtDate = [localDate dateByAddingTimeInterval: -interval];
    return gmtDate;
}

+(NSDate *)strToDate:(NSString *)dateStr withFormat:(NSString *)formatStr{
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    if ([clsCommonFunc isEmptyStr:formatStr]) {
        [formater setDateFormat:@"yyyy-MM-dd"];
    }
    else
        [formater setDateFormat:formatStr];
    NSDate *theDate=[formater dateFromString:dateStr];
    //直接format出来的日期有时分秒导致可能会变,如"2018-12-31"会变成2018-12-30 16:00:00 +0000需要getLocalDateFromGMTDate转成日期的0时0分0秒2018-12-31 00:00:00 +0000
    return [self getLocalDateFromGMTDate:theDate];
}



+(NSDate *)getOtherDateThenDate:(NSDate *)nowDate offset:(CGFloat)iDay{
    //获取指定日期的前几天或后几天的日期，包括当天
    NSDate *theDate;
    NSTimeInterval oneDay=24*60*60;//1天的长度(秒)
    theDate = [nowDate dateByAddingTimeInterval:oneDay*iDay]; //iDay为正后几天，为负表示前几天
    return theDate;
}

+ (NSInteger)numberOfDaysFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
//获取2个日期间隔的天数，不包括当天
NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
NSDateComponents *comp =[calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:NSCalendarWrapComponents];
return comp.day;//fromData<toDate时返回正数，否则为负数
}


+(NSString *)arr2String:(NSArray *)arr withJGF:(NSString *)jgf{
    NSString *result=@"";
    if (arr && [arr count]>0) {
        result=[arr objectAtIndex:0];
        if ([arr count]>1){
            for (int i=1; i<[arr count]-1; i++) {
                result=[result stringByAppendingFormat:@",%@",[arr objectAtIndex:i]];
            }
        }
    }
    return result;
}

+(UILabel *)initALabel:(NSString *)text textfont:(UIFont *)font textColor:(UIColor*)color textAlign:(NSTextAlignment)alignment{
    UILabel *tmpLabel=[[UILabel alloc]init];
    tmpLabel.text=text;
    tmpLabel.font=font;
    tmpLabel.textColor=color;
    if (alignment) {
        tmpLabel.textAlignment=alignment;
    }
    else
        tmpLabel.textAlignment=NSTextAlignmentLeft;
    
    return tmpLabel;
}

+(UILabel *)initALabel:(NSString *)text textfont:(UIFont *)font textColor:(UIColor*)color textAlign:(NSTextAlignment)alignment andTarget:(id)target andAction:(SEL)action{
    UILabel *tmpLabel=[self initALabel:text textfont:font textColor:color textAlign:alignment];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [tmpLabel addGestureRecognizer:tap];
    tmpLabel.userInteractionEnabled=YES;
    return tmpLabel;
}



+(UIButton *)initAButtonWithImage:(UIImage *)btnImg andTarget:(id)target andAction:(SEL)action{
//+(UIButton *)initAButtonWithImage:(UIImage *)btnImg andTarget:(nonnull id)target andAction:(nonnull SEL)action{
    UIButton *tmpBtn=[[UIButton alloc]init];
    [tmpBtn setImage:btnImg forState:UIControlStateNormal];
    [tmpBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return tmpBtn;
}

+(UIButton *)initAButtonWithTitle:(NSString *)title andBorderColor:(UIColor *)color andCorner:(CGFloat)cornerRadius andTarget:(id)target andAction:(SEL)action{
    UIButton *tmpBtn=[[UIButton alloc]init];
    [tmpBtn setTitle:title forState:UIControlStateNormal];
    [tmpBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    if (cornerRadius>0) {
        tmpBtn.layer.cornerRadius=cornerRadius;
    }
    
    if (color) {
        tmpBtn.layer.borderWidth=1;
        tmpBtn.layer.borderColor=[color CGColor];
        [tmpBtn setTitleColor:color forState:UIControlStateNormal];
    }
    
    return tmpBtn;
}

+(UIButton *)initAButtonWithFrame:(CGRect)frame andBorderColor:(UIColor *)color andCorner:(CGFloat)cornerRadius andTarget:(id)target andAction:(SEL)action{
    UIButton *tmpBtn=[[UIButton alloc]initWithFrame:frame];
    [tmpBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    if (cornerRadius>0) {
        if(color)
            [tmpBtn roundCornerWithCornerRadii:CGSizeMake(cornerRadius, cornerRadius) andCorners:UIRectCornerAllCorners andBordWidth:1 andBordColor:color];
        else
            [tmpBtn roundCornerWithCornerRadii:CGSizeMake(cornerRadius, cornerRadius) andCorners:UIRectCornerAllCorners];
    }
    if (color) {
        [tmpBtn setTitleColor:color forState:UIControlStateNormal];
    }
    return tmpBtn;
}

+(UIButton *)initAButtonWithBackImage:(UIImage *)btnImg andTarget:(id)target andAction:(SEL)action{
//+(UIButton *)initAButtonWithBackImage:(UIImage *)btnImg andTarget:(nonnull id)target andAction:(nonnull SEL)action{
    UIButton *tmpBtn=[[UIButton alloc]init];
    [tmpBtn setBackgroundImage:btnImg forState:UIControlStateNormal];
    [tmpBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return tmpBtn;
}


//初化带tap的uiimageView
+(UIImageView *)initAImageViewWithImage:(UIImage *)image andTarget:(id)target andAction:(SEL)action{
//+(UIImageView *)initAImageViewWithImage:(UIImage *)image andTarget:(nonnull id)target andAction:(nonnull SEL)action{
    UIImageView *resultImgView=[[UIImageView alloc]initWithImage:image];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [resultImgView addGestureRecognizer:tap];
    resultImgView.userInteractionEnabled=YES;
    return resultImgView;
}

+(NSArray *)separatedString:(NSString *)str ByString:(NSString *)split{
    if ([self isEmptyStr:str] || [self isEmptyStr:split]) {
        return nil;
    }
    return [str componentsSeparatedByString:split];
}

+(void)PushDetailViewControll:(UIViewController *)detailVC byNaviController:(UINavigationController *)naviVC  andHide:(BOOL)hideFlag{
    naviVC.navigationBarHidden = hideFlag;
    [naviVC pushViewController:detailVC animated:NO];
}

+(void)animatePushDetailViewControll:(UIViewController *)detailVC byNaviController:(UINavigationController *)naviVC  andHide:(BOOL)hideFlag withAnimate:(NSAimateType)iAnimate{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    switch (iAnimate) {
        case animate_Fade:
            transition.type =kCATransitionFade;
            break;
        case animate_Push_L:
            transition.type =kCATransitionPush;//动画效果
            transition.subtype = kCATransitionFromLeft; //动画方向
            break;
        case animate_Push_R:
            transition.type =kCATransitionPush;
            transition.subtype = kCATransitionFromRight;
            break;
        case animate_Push_T:
            transition.type =kCATransitionPush;
            transition.subtype = kCATransitionFromTop;
            break;
        case animate_Push_B:
            transition.type =kCATransitionPush;
            transition.subtype = kCATransitionFromBottom;
            break;
        case animate_MoveIN_L:
            transition.type =kCATransitionMoveIn;
            transition.subtype = kCATransitionFromLeft;
            break;
        case animate_MoveIN_R:
            transition.type =kCATransitionMoveIn;
            transition.subtype = kCATransitionFromRight;
            break;
        case animate_MoveIN_T:
            transition.type =kCATransitionMoveIn;
            transition.subtype = kCATransitionFromTop;
            break;
        case animate_MoveIN_B:
            transition.type =kCATransitionMoveIn;
            transition.subtype = kCATransitionFromBottom;
            break;
        case animate_Reveal_L:
            transition.type =kCATransitionReveal;
            transition.subtype = kCATransitionFromLeft;
            break;
        case animate_Reveal_R:
            transition.type =kCATransitionReveal;
            transition.subtype = kCATransitionFromRight;
            break;
        case animate_Reveal_T:
            transition.type =kCATransitionReveal;
            transition.subtype = kCATransitionFromTop;
            break;
        case animate_Reveal_B:
            transition.type =kCATransitionReveal;
            transition.subtype = kCATransitionFromBottom;
            break;
        case animate_Flip:
            transition.type =@"oglFlip";
            break;
        case animate_Cube_L:
            transition.type =@"cube";
            transition.subtype = kCATransitionFromLeft;
            break;
        case animate_Cube_R:
            transition.type =@"cube";
            transition.subtype = kCATransitionFromRight;
            break;
        case animate_Cube_T:
            transition.type =@"cube";
            transition.subtype = kCATransitionFromTop;
            break;
        case animate_Cube_B:
            transition.type =@"cube";
            transition.subtype = kCATransitionFromBottom;
            break;
        case animate_PageCurl_L:
            transition.type =@"pageCurl";
            transition.subtype = kCATransitionFromLeft;
            break;
        case animate_PageCurl_R:
            transition.type =@"pageCurl";
            transition.subtype = kCATransitionFromRight;
            break;
        case animate_PageCurl_T:
            transition.type =@"pageCurl";
            transition.subtype = kCATransitionFromTop;
            break;
        case animate_PageCurl_B:
            transition.type =@"pageCurl";
            transition.subtype = kCATransitionFromBottom;
            break;
        case animate_PageUncurl_L:
            transition.type =@"pageUnCurl";
            transition.subtype = kCATransitionFromLeft;
            break;
        case animate_PageUncurl_R:
            transition.type =@"pageUnCurl";
            transition.subtype = kCATransitionFromRight;
            break;
        case animate_PageUncurl_T:
            transition.type =@"pageUnCurl";
            transition.subtype = kCATransitionFromTop;
            break;
        case animate_PageUncurl_B:
            transition.type =@"pageUnCurl";
            transition.subtype = kCATransitionFromBottom;
            break;
        case animate_RippleEffect:
            transition.type =@"rippleEffect";
            break;
        case animate_SuckEffect:
            transition.type =@"suckEffect";
            break;
        case animate_cameraIrisHollowOpen:
            transition.type =@"cameraIrisHollowOpen";
            break;
        case animate_cameraIrisHollowClose:
            transition.type =@"cameraIrisHollowClose";
            break;
        default:
            transition.type =kCATransitionFade;
            break;
    }
    [naviVC.view.layer addAnimation:transition forKey:nil];
    [naviVC setNavigationBarHidden:hideFlag];
//    self.navigationItem.backBarButtonItem=[[UIBarButtonItemalloc] initWithTitle:@”返回“style:UIBarButtonItemStyleBorderedtarget:nilaction:nil];
    //修改自动添加的返回按钮back为返回
    [naviVC pushViewController:detailVC animated:NO];
    //animated为YES时有切换动画效果，特别是为kCATransitionFade时，animated为NO则没有方向切换效果，为YES时则有方向交叉切换效果
}

+(void)randAnimatePushDetailViewControll:(UIViewController *)detailVC byNaviController:(UINavigationController *)naviVC andHide:(BOOL)hideFlag{
    NSInteger iRand=arc4random()%21; //0-20
    [self animatePushDetailViewControll:detailVC byNaviController:naviVC andHide:hideFlag withAnimate:iRand];
}

+(NSString *)getRandomStringWithLength:(NSInteger)iLen{
    NSInteger iRnd=arc4random()%9+1;
    NSString *result=[NSString stringWithFormat:@"%ld",(long)iRnd];
    
    for(int i=1;i<iLen;i++){
        iRnd=arc4random()%10;//0-9
        result=[result stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)iRnd]];
    }
    return result;
}

+(NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
//    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
//                                                           mutabilityOption:NSPropertyListImmutable
//                                                                     format:NULL
//                                                           errorDescription:NULL];
   NSString* returnStr=[NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:nil];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

+(BOOL)isEmptyStr:(NSString *)str{
    if ([str isKindOfClass:[NSNull class]])
        return YES;
    if (![str isKindOfClass:[NSString class]])
        return YES;
    //需先判断是否为NSString类型，否为为NULL或其他类型时，此调用[str isEmptyString]会崩溃
    return (!str || [str isEmptyString]);
}

+(BOOL)isHttpStr:(NSString *)str{
    if ([self isEmptyStr:str]) {
        return NO;
    }
    return [str hasPrefix:@"http"];
}

+(BOOL)isPushOpened{
    if (@available(iOS 8.0, *)){ //if (IS_IOS8){
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types  == UIUserNotificationTypeNone) {
            return NO;
        }
    }else{ // ios7 以下
        if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes]  == UIRemoteNotificationTypeNone) {
            return NO;
        }
    }
    return YES;
}

+(void)copyWordsToPasteboard:(NSString *)keyWord{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:keyWord];
}


+(id)readDatasFromJsonFile:(NSString *)sfileName ifUtf8:(BOOL)utf8Flag{
//    NSArray *resultArr=nil;
    NSString *sfilePath=_APP_PATHFORRESOURCE(sfileName, nil);
    NSString *lrcString =(utf8Flag?[NSString stringWithContentsOfFile:sfilePath encoding:NSUTF8StringEncoding error:nil]:[NSString stringWithContentsOfFile:sfilePath encoding:NSUnicodeStringEncoding error:nil]);
    if (lrcString) {
        NSDictionary *tmpDict=[lrcString toJsonDict];
        return tmpDict;
    }
    return lrcString;
}

+(void)async2mainQueueWithUIPro:(dispatch_block_t)uiProblock{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (uiProblock) {
            uiProblock();
        }
    });
}

+(void)async2GlobalQueueWithUIPro:(dispatch_block_t)htProblock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (htProblock) {
            htProblock();
        }
    });
}

+(void)popNaviController:(UINavigationController *)navigationController animate:(BOOL)flag{
    [navigationController popViewControllerAnimated:flag];
}


+(BOOL)isValidateDict:(id)dict{
    if (!dict) {
        return NO;
    }
    if ([dict isKindOfClass:[NSNull class]])
        return NO;
    if (![dict isKindOfClass:[NSDictionary class]] && ![dict isKindOfClass:[NSMutableDictionary class]]) {
        return NO;
    }
    return ([dict count]>0);
}

+(BOOL)isValidateArr:(id)arr{
    if (!arr) {
        return NO;
    }
    if ([arr isKindOfClass:[NSNull class]])
        return NO;
    if (![arr isKindOfClass:[NSArray class]] && ![arr isKindOfClass:[NSMutableArray class]]) {
        return NO;
    }
    return ([arr count]>0);
}

+(BOOL)isValidateData:(id)data{
    if (!data) {
        return NO;
    }
    if ([data isKindOfClass:[NSNull class]])
        return NO;
    if (![data isKindOfClass:[NSData class]]) {
        return NO;
    }
    return ([data length]>0);
}

+(void)gotoAppConfigUI{
   
    if (@available(iOS 10.0, *))
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

+(NSDictionary *)theNLInfoOfDay:(nonnull NSDate *)aDay{
    //返回农历信息 如：year:甲子 month:九 day:十一 leapMoth:number(YES/NO)
    NSCalendar *gregorian_RL = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];//农历
    unsigned unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSDateComponents *localeComp = [gregorian_RL components:unitFlags fromDate:aDay];
//    NSDateComponents数据格式如下： <NSDateComponents: 0x134e65480>
//        Calendar Year: 35
//        Month: 9
//        Leap month: no
//        Day: 14
    NSArray *chineseYears = [NSArray arrayWithObjects:@"甲子", @"乙丑", @"丙寅", @"丁卯",@"戊辰",@"己巳",@"庚午",@"辛未",@"壬申",@"癸酉",
                             @"甲戌", @"乙亥",@"丙子",@"丁丑", @"戊寅", @"己卯",@"庚辰",@"辛己",@"壬午",@"癸未",
                             @"甲申", @"乙酉",@"丙戌",@"丁亥",@"戊子",@"己丑",@"庚寅",@"辛卯",@"壬辰",@"癸巳",
                             @"甲午", @"乙未",@"丙申",@"丁酉",@"戊戌",@"己亥",@"庚子",@"辛丑",@"壬寅",@"癸丑",
                             @"甲辰", @"乙巳",@"丙午",@"丁未",@"戊申",@"己酉",@"庚戌",@"辛亥",@"壬子",@"癸丑",
                             @"甲寅", @"乙卯",@"丙辰",@"丁巳",@"戊午",@"己未",@"庚申",@"辛酉",@"壬戌",@"癸亥", nil];
    NSArray *chineseMonths=[NSArray arrayWithObjects:
                            @"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",@"九月", @"十月", @"冬月", @"腊月", nil];
    
    NSArray *chineseDays=[NSArray arrayWithObjects:@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",nil];
    NSString *y_str = [chineseYears objectAtIndex:localeComp.year-1];
    NSString *m_str = [chineseMonths objectAtIndex:localeComp.month-1];
    NSString *d_str = [chineseDays objectAtIndex:localeComp.day-1];
    
    return @{@"year":y_str,@"month":m_str,@"day":d_str,@"leapmonth":[NSNumber numberWithBool:localeComp.leapMonth]};
    
}

+(NSString *)theShengXiaoOfYear:(NSString *)year{
    NSDictionary *tmpDict=@{@"子":@"鼠",@"丑":@"牛",@"寅":@"虎",@"卯":@"兔",@"辰":@"龙",@"巳":@"蛇",@"午":@"马",@"未":@"羊",@"申":@"猴",@"酉":@"鸡",@"戌":@"狗",@"亥":@"猪"};
    return [tmpDict objectForKey:year];
}

+(NSInteger)theWeakIndexOfDay:(NSDate *)aDay{
    //获取星期的index，0=周日
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =[gregorian components:NSCalendarUnitWeekday fromDate:aDay];
    return [weekdayComponents weekday];
}

+(NSString *)getWeekStrByIndex:(NSInteger)iWeek andType:(BOOL)longtype{
    NSString *weakStr=longtype?@"星期日":@"周日";
    switch (iWeek) {
        case 1:
            weakStr= longtype?@"星期日":@"周日";
            break;
        case 2:
            weakStr= longtype?@"星期一":@"周一";
            break;
        case 3:
            weakStr= longtype?@"星期二":@"周二";
            break;
        case 4:
            weakStr= longtype?@"星期三":@"周三";
            break;
        case 5:
            weakStr= longtype?@"星期四":@"周四";
            break;
        case 6:
            weakStr= longtype?@"星期五":@"周五";
            break;
        case 7:
            weakStr= longtype?@"星期六":@"周六";
            break;
        default:
            break;
    }
    return weakStr;
}


+(NSString *)confirmDictStringObject:(id)obj{
    //    NSString *str= [NSString stringWithFormat:@"%@",[dict objectForKey:@"kay"]];//此种写法，如果无kay项，则str的值会为@"(null)"，导致判断错乱
    //所以为了确认此项是否有值
    if (!obj) {
        return @"";
    }
    if ([obj isKindOfClass:[NSNull class]]) {
        return @"";
    }
    NSString *result=[NSString stringWithFormat:@"%@",obj];//如果obj是number类型的int或double，也可以这样直接转成NSString类型
    if ([result isEqualToString:@"<null>"]) {
        return @"";
    }
    return result;
}

+(NSString *)confirmDictStringObject:(id)obj withDefaultValue:(NSString *)defValue{
    if (!obj) {
        return defValue;
    }
    return [NSString stringWithFormat:@"%@",obj];
}

//截取原图指定区域的图像
+(UIImage *)getAImageFromSourceImage:(UIImage *)sourceImg withRect:(CGRect)rect{
//    UIImage *imageSBX=_IMAGE(@"push_alert_left.png", nil);//140*140(只截取原图的140*25的大小即可,缩放会变形)
    CGImageRef ir = CGImageCreateWithImageInRect(sourceImg.CGImage, rect);
    UIImage *subImage = [UIImage imageWithCGImage:ir];
    CGImageRelease(ir);//释放图片所占的内存
    return subImage;
}

//将原图指定区域进行tile填充放大
+(UIImage *)enlargeSourceImage:(UIImage *)sourceImg withEdge:(UIEdgeInsets)edge{
     return [sourceImg resizableImageWithCapInsets:edge resizingMode: UIImageResizingModeTile];
}

+(UIViewController *)viewControllerWithClass:(Class)vcClass forView:(UIView *)view{
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if (vcClass) {
            if ([nextResponder isKindOfClass:vcClass]) {
                return (UIViewController *)nextResponder;
            }
        }
        else{
            if ([nextResponder isKindOfClass:[UIViewController class]]) {
                return (UIViewController *)nextResponder;
            }
        }
    }
    return nil;
}


+(NSArray *)randAListData:(NSArray *)listData{
    NSMutableArray *nutableArray = [[NSMutableArray alloc]initWithArray:listData];
    int i = (int)[nutableArray count];
    while (--i>0) {
        int j=rand()%(i+1); //0~i
        [nutableArray exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    return [NSArray arrayWithArray:nutableArray];
}

/**
 解决将图片保存至沙箱后，取出时方向不对的问题，保存image前，将image转换一下再保存
 @param aImage 要保存的image
 @return 转换后可以保存至沙箱的image
 */
+(UIImage *)fixImageOrientation:(UIImage *)aImage
{
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        }
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        }
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        }
        default:
            break;
    }
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        }
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        }
        default:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height, CGImageGetBitsPerComponent(aImage.CGImage), 0, CGImageGetColorSpace(aImage.CGImage), CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
        }
        default:
        {
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
        }
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}





@end
