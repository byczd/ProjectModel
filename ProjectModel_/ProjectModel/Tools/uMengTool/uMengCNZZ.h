//
//  uMengCNZZ.h
//  nightRain
//
//  Created by chenQiaoxin on 2018/3/21.
//  Copyright © 2018年 chenQiaoxin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EVENT_NAVIPAGE @"event_naviPage"
#define EVENT_ENTER @"event_Enter"
#define EVENT_TOOLBAR @"pp_toolbar_event"
#define EVENT_HOMEPAGE @"pp_home_page_event"
#define EVENT_VIDEOPAGE @"pp_video_page_event"
#define EVENT_CONTENTPAGE @"pp_content_page_event"
#define EVENT_TOOLSPAGE @"pp_tools_page_event"
#define EVENT_MINEPAGE @"pp_mine_page_event"
#define EVENT_WXTXPAGE @"pp_wxtxian_page_event"
#define EVENT_WELCOMEPAGE @"pp_welcome_page_event"
#define EVENT_SAFE @"event_report_safeusr"
#define EVENT_ADS @"event_report_Ads"
#define EVENT_LOGIN @"event_Login"
#define EVENT_BACK_ERRDATA @"event_Back_ErrData"
#define EVENT_REPORT @"event_Report"
#define EVENT_WALKPAGE @"pp_walkpage_event"

#define _locate_state_0 @"SHOWLOCATEREQUEST"
#define _locate_state_1 @"SHOWLOCATEALERT"

#define KEY_LOCAL_DL @"key_local_area"
#define KEY_LOCAL_FW @"key_local_sx"
#define KEY_WAIWAI_DL @"key_wai_data"
#define KEY_WAIWAI_INFO @"key_wai_info"
#define KEY_WFWF_INFO @"key_wfwf_info"
#define KEY_WILAN_COUNT @"key_wlf_cnt"
#define KEY_WEIGHT_INFO @"key_weight_sj"
#define KEY_STEP_INFO @"key_step_cnt"
#define CNZZ_EVENT @"event_business"
#define CNZZ_EVENT_USER @"event_business_user"
#define KEY_ROOT_TIME @"key_last_root"
#define KEY_BATT_INFO @"key_batt_info"
#define KEY_ALBUM_PRIOR @"key_album_prior"

#define KEY_LOCAL_CLD @"key_local_cld"
#define KEY_LOCAL_CTD @"key_local_ctd"
#define KEY_LOCAL_IDF @"key_local_idf"
#define KEY_LOCAL_SIM @"key_local_smi"

#define KEY_MAIN_PROGRESS @"pp_key_progress"
//关键步骤来源+关键步骤流失  从A到B的步骤及流失率

@interface uMengCNZZ : NSObject
+(void)uMengInit;
+(void)uMengEventWithEventID:(NSString *)eventID andEventType:(NSString *)eventType;

+(void)uMengEventWithEventID:(NSString *)eventId withAttributes:(NSDictionary *)attributes;
+(void)uMengPageWithPageID:(NSString *)pageID andLoginType:(BOOL)isEnter;
+(void)uMengEventWithDefaultDictAndEventID:(NSString *)eventID andType:(NSString *)sType andDetail:(NSString *)sDetail;
+(void)uMengEventWithEventID:(NSString *)eventId attributes:(NSDictionary *)attributes number:(NSNumber *)number;

+(BOOL)uMengPirated;
+(BOOL)uMengJailbroken;
+(NSString *)iOSBootTime;
+(void)cnzzLocation:(NSString *)city;
+(void)cnzzErrbackdata:(NSString *)lx andMemo:(NSString *)memo;
+(void)uMengEventWithWarnInfo:(NSString *)warn andmemo:(NSString *)memo;
+(void)getThumbnailImages;
+(void)uMengCarrierInfo;
+(void)getAppleIDClientIdentifier;
@end
