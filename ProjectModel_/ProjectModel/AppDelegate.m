//
//  AppDelegate.m
//  ProjectModel
//
//  Created by 黄龙 on 2019/10/14.
//  Copyright © 2019年 adong. All rights reserved.
//

#import "AppDelegate.h"

#import <UserNotifications/UserNotifications.h>

#import <AdSupport/AdSupport.h>
#import "JPUSHService.h"

#import "ppreadSharing.h"

//极光推送
static NSString *jgPushKey =@"d3f01a1294015bf70c39dc17";
static NSString *jgPushchannel = @"AppStore";

@interface AppDelegate ()<JPUSHRegisterDelegate>//QQApiInterfaceDelegate,TencentLoginDelegate

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //----------极光推送
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    // 3.0.0及以后版本注册可以这样写，也可以继续用旧的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:jgPushKey
                          channel:jgPushchannel
                 apsForProduction:FALSE
            advertisingIdentifier:advertisingId];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            debugLog(@"JPUSHService-registrationID-Success,registrationID=%@",registrationID);
        }
        else{
            debugLog(@"JPUSHService-registrationID-Fail,resCode：%d",resCode);
        }
    }];
    [JPUSHService setLogOFF];
    
    
    //-----------友盟的方法本身是异步执行，所以不需要再异步调用
//    [uMengCNZZ uMengInit];
    
    //-----------微信分享
    //微信注册 1.7.1版本
    //[WXApi registerApp:WechatAppID withDescription:WechatAppSecret];
    //微信注册1.8版
    [WXApi registerApp:WechatAppID enableMTA:YES];
    //向微信注册支持的文件类型
    UInt64 typeFlag =MMAPP_SUPPORT_NOCONTENT| MMAPP_SUPPORT_TEXT | MMAPP_SUPPORT_PICTURE | MMAPP_SUPPORT_LOCATION | MMAPP_SUPPORT_VIDEO |MMAPP_SUPPORT_AUDIO | MMAPP_SUPPORT_WEBPAGE | MMAPP_SUPPORT_DOC | MMAPP_SUPPORT_DOCX | MMAPP_SUPPORT_PPT | MMAPP_SUPPORT_PPTX | MMAPP_SUPPORT_XLS | MMAPP_SUPPORT_XLSX | MMAPP_SUPPORT_PDF;
    [WXApi registerAppSupportContentFlag:typeFlag];
    
    //-------------qq分享
   TencentOAuth *tencentOAuth=[[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:nil];
    debugLog(@"%@",tencentOAuth.accessToken);
    //------------------------

    
    // 如果 App 状态为未运行，此函数将被调用，如果 launchOptions 包含 UIApplicationLaunchOptionsRemoteNotificationKey 表示用户点击 apn 通知导致 app 被启动运行；
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    if ([clsCommonFunc isValidateDict:remoteNotification]) {
        [self runWithNotiMessage:remoteNotification inLocalState:NO];
    }
    else{
        //   如果 App 状态为未运行，此函数将被调用，如果 launchOptions 包含 UIApplicationLaunchOptionsLocalNotificationKey 表示用户点击本地通知导致 app 被启动运行；
        NSDictionary *localNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey];
        if ([clsCommonFunc isValidateDict:localNotification]) {
            [self runWithNotiMessage:localNotification inLocalState:YES];
        }
    }
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



//#pragma mark- QQApiInterfaceDelegate
///**
// 处理来至QQ的请求
// */
//- (void)onReq:(QQBaseReq *)req{
//}
//
//- (void)onResp:(QQBaseResp *)resp
//{
//    //qq分享结果 如果为0，表示分享成功。 -4表示取消分享
//    if (resp.result.length != 0) {
//        dispatch_async(dispatch_get_main_queue(), ^{//发送的消息可能不在主线程,如果直接postNoti可能导致主线程收到消息过慢
//            NSDictionary *dictionary = nil;
//            dictionary = [NSDictionary dictionaryWithObjectsAndKeys:resp.result,@"result",nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:QQ_SHARE_RESULT object:self userInfo:dictionary];
//        });
//    }
//}
//
///**
// 处理QQ在线状态的回调
// */
//- (void)isOnlineResponse:(NSDictionary *)response{
//
//}


#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger options))completionHandler{
    // Required
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}
/*
 * @brief handle UserNotifications.framework [didReceiveNotificationResponse:withCompletionHandler:]
 * @param center [UNUserNotificationCenter currentNotificationCenter] 新特性用户通知中心
 * @param response 通知响应对象
 * @param completionHandler
 */
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    completionHandler();  // 系统要求执行这个方法
}


- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification{
}

#pragma mark- 通知打开的App处理

/**
 打开push时，
 首先触发此runWithNotiMessage
 然后再是jpushNotificationCenter
 notimessage 消息体
 isLocal=yes为本地通知
 */
-(void)runWithNotiMessage:(NSDictionary *)notimessage inLocalState:(BOOL)isLocal{
    _DefaultUserSaveOjbectForKey(@"isPushBoot", @"_def_boot_type");
    _DefaultUserSure;
}

@end
