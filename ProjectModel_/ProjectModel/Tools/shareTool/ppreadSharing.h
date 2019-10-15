//
//  ppreadSharing.h
//  paopaoread
//
//  Created by 七七 on 2017/12/18.
//  Copyright © 2017年 paopaoread. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WXApi.h"
#import "WXApiManager.h"
#import "WXApiResponseHandler.h"

//#import <TencentOpenAPI/TencentOAuthObject.h>
//#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

//微信分享
#define WechatAppID     @"wx4cdea4a057591035" // @"wx259a7ec404d73570"
//#define WechatAppSecret @"2915bc48d17985d32175e44a14b8ed9f" //@"bc8bc7c256f0d5ccf46a5ca8ce0447b6"
//qq分享
#define QQAppID      @"101538104" //@"101509724" //plist中scheme也要改成：101509724
//#define QQAppSecret  @"8m7uWgUxl6qA2PLv"
//#define QQAppKey @"a64ca4f829c8b9eb28a4a7b3dbfecc57"

//qq包名
#define QM_QQ_PACKAGE      @"com.tencent.mqq"

//微信包名
#define QM_WEIXIN_PACKAGE    @"com.tencent.xin"

//从微信跳转过来的时候，获取weixinopenid和appid
#define PLAY_ONL_MUSIC   @"UExBWV9PTkxfTVVTSUM"

//qq分享成功的通知
#define  QQ_SHARE_RESULT    @"QQShareResult"


@interface ppreadSharing : NSObject
//+(void)proWechatShare:(NSString *)shareInfo failure:(void(^)(NSString * errInfo))failure;
//+(void)proPoetryShare:(NSString *)shareInfo forID:(NSString *)appID withView:(UIView *)theView failure:(void(^)(NSString * errInfo))failure;
//+(void)proQqShare:(NSString *)shareInfo withView:(UIView *)theView failure:(void(^)(NSString * errInfo))failure;

+(void)proWechatShareWithInfo:(NSDictionary *)shareInfo failure:(void(^)(NSString * errInfo))failure;
+(void)proQQShareWithInfo:(NSDictionary *)shareInfo failure:(void(^)(NSString * errInfo))failure;

+(void)proInviteInType:(NSInteger)iType WithShareInfo:(NSDictionary *)shareInfo failure:(void(^)(NSString * errInfo))failure;
@end
