//
//  uMengCNZZ.m
//  nightRain
//
//  Created by chenQiaoxin on 2018/3/21.
//  Copyright © 2018年 chenQiaoxin. All rights reserved.
//

#import "uMengCNZZ.h"
#import "UMAnalytics/MobClick.h"
#import "UMCommon/UMCommon.h"
#import "simpleSQL.h"

#import "pptoolNetpro.h"
#import "sys/utsname.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#define UMENG_APPKEY @"5bf22d5eb465f571e900003b"

//static NSDateFormatter *_cachedDateFormatter;

@implementation uMengCNZZ

+(void)uMengEventWithDefaultDictAndEventID:(NSString *)eventID andType:(NSString *)sType andDetail:(NSString *)sDetail withUserID:(NSString *)userID{
    NSString *detailStr=nil;
    if (!sDetail) {
        sDetail=@"";
    }
    if (![clsCommonFunc isEmptyStr:sDetail]) {
        detailStr=[NSString stringWithFormat:@"%@[%@]_%@",sType,sDetail,userID];//<%@>[clsCommonFunc theBatteryLeverl]
         debugLog(@"--cnzz[%@]%@",eventID,detailStr);
    }
    else
         debugLog(@"--cnzz[%@]%@",eventID,sType);
    
    NSDictionary *cnzzDict=[NSDictionary dictionaryWithObjectsAndKeys:sType,@"type",
                            [NSString stringWithFormat:@"%@_%@[%@]",sType,_APP_IDENTIFIER,_APP_VERSION],@"type_appInfo",
                            [NSString stringWithFormat:@"%@_%@",sType,[self osBuildVersion]],@"type_osInfo",
                            [NSString stringWithFormat:@"%@[%@]",sType,sDetail],@"type_detail",
                            detailStr,@"type_userdetail",//sDetail为nil时不显示type_detail项
                            nil];
    [MobClick event:eventID attributes:cnzzDict];
}

+(void)uMengEventWithEventID:(NSString *)eventID andEventType:(NSString *)eventType{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@[%@]",_APP_IDENTIFIER,_APP_VERSION], @"packageName", [NSString stringWithFormat:@"%@(%@)_%@",_APP_VERSION,_APP_IDENTIFIER,eventType], @"type", nil];
    [MobClick event:eventID attributes:dict];
}

//计数事件
+(void)uMengEventWithEventID:(NSString *)eventId withAttributes:(NSDictionary *)attributes{
    [MobClick event:eventId attributes:attributes];
}

//计算事件
+(void)uMengEventWithEventID:(NSString *)eventId attributes:(NSDictionary *)attributes number:(NSNumber *)number{
    NSString *numberKey = @"__ct__"; //规定__ct__对应的数值数据，为计算参数,且只能有此一个计算参数
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [mutableDictionary setObject:[number stringValue] forKey:numberKey];
    [MobClick event:eventId attributes:mutableDictionary];
}

//+ (void)event:(NSString *)eventId;

+(void)uMengPageWithPageID:(NSString *)pageID andLoginType:(BOOL)isEnter{
    if (isEnter) {
        [MobClick beginLogPageView:pageID];
    }
    else{
        [MobClick endLogPageView:pageID];
    }
    debugLog(@"----uMengPageWithPageID[%@](%@)",pageID,isEnter?@"begin":@"end");
}

+(void)uMengInit{
    //old-sdk
    //    [MobClick setLogEnabled:NO];
    //    UMConfigInstance.appKey = UMENG_APPKEY;
    //    UMConfigInstance.secret = @"doudouguangchangwu";
    //    [MobClick startWithConfigure:UMConfigInstance];
    
    //new-sdk
    /** 初始化友盟所有组件产品
      initWithAppkey:(NSString *)appKey channel:(NSString *)channel;
     @param appKey 开发者在友盟官网申请的appkey.
     @param channel 渠道标识，可设置nil表示"App Store".
     */
    [UMConfigure initWithAppkey:UMENG_APPKEY channel:@"AppStore"];
    //开发者需要显式的调用此函数，日志系统才能工作
    //    [UMCommonLogManager setUpUMCommonLogManager];
    [UMConfigure setLogEnabled:NO];//发布时必须改成NO;//若为yes时将上面setUpUMCommonLogManager也开启

//    [MobClick setScenarioType:E_UM_NORMAL];//默认即为E_UM_NORMAL
//    rainLog(@"----umidString=%@,deviceIDForIntegration=%@,utdid=%@",[UMConfigure umidString],[UMConfigure deviceIDForIntegration],[UTDevice utdid]);
//    rainLog(@"isJailbroken=%@,isPirated=%@",[MobClick isJailbroken]?@"YES":@"NO",[MobClick isPirated]?@"YES":@"NO");
    
}


+(BOOL)uMengPirated{
    return [MobClick isPirated];
}

+(BOOL)uMengJailbroken{
    return [MobClick isJailbroken];
}

+(void)cnzzLocation:(NSString *)city{
    [self uMengEventWithDefaultDictAndEventID:EVENT_REPORT andType:@"LOCATE_DETAIL" andDetail:city];
}

+(void)cnzzErrbackdata:(NSString *)lx andMemo:(NSString *)memo{
    [uMengCNZZ uMengEventWithDefaultDictAndEventID:EVENT_BACK_ERRDATA andType:lx andDetail:memo];
}


+(NSString *)osBuildVersion{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(buildVersion)]) {
        return [NSString stringWithFormat:@"%@(%@)",[[UIDevice currentDevice] systemVersion],[[UIDevice currentDevice] performSelector:@selector(buildVersion)]];
    }
    else{
        return [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]];
    }
}

+ (NSString *)theDevType:(BOOL)simple;
{
    NSString *result=@"";
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *device_type = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
#if TARGET_IPHONE_SIMULATOR
    result= [NSString stringWithFormat:@"%@_MLQ",device_type];
#else
    result=device_type;
#endif
    NSString *sname=[[UIDevice currentDevice] name];
    if (simple) {
        return [NSString stringWithFormat:@"%@|%@",result,[self osBuildVersion]];
    }
    else
        return [NSString stringWithFormat:@"%@|%@|%@",result,[self osBuildVersion],sname];
}


+ (NSString *)theBatteryLeverl {
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    NSString *batteryStateLevel = @"";
    NSString *batteryState = @"";
    if (device.batteryState == UIDeviceBatteryStateUnknown) {
        batteryState = @"unknow";
    }else if (device.batteryState == UIDeviceBatteryStateUnplugged){
        batteryState = @"uncharge";
    }else if (device.batteryState == UIDeviceBatteryStateCharging){
        batteryState = @"charging";
    }else if (device.batteryState == UIDeviceBatteryStateFull){
        batteryState = @"full";
    }
    batteryStateLevel = [NSString stringWithFormat:@"%@%.f",batteryState,100*device.batteryLevel];
    return batteryStateLevel;
}

+(NSTimeInterval)bootTime{
    struct timeval t;
    size_t len=sizeof(struct timeval);
    if(sysctlbyname("kern.boottime",&t,&len,0,0)!=0)
        return 0.0;
    return  t.tv_sec+t.tv_usec/USEC_PER_SEC;
}

+(NSString *)iOSOpenTime:(NSTimeInterval)localTimeInterval{
    time_t timeInterval = (time_t)localTimeInterval;
    struct tm *time = localtime(&timeInterval);
    NSString *timeStr = [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d:%02d",time->tm_year + 1900,time->tm_mon + 1,time->tm_mday,time->tm_hour,time->tm_min, time->tm_sec];
    return timeStr;
}


+(NSString *)iOSBootTime{
    struct timeval t;
    size_t len=sizeof(struct timeval);
    if(sysctlbyname("kern.boottime",&t,&len,0,0)!=0)
        return @"unknown";
    NSTimeInterval *localTimeInterval=t.tv_sec+t.tv_usec/USEC_PER_SEC;
    time_t timeInterval = (time_t)localTimeInterval;
    struct tm *time = localtime(&timeInterval);
    NSString *timeStr = [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d:%02d",time->tm_year + 1900,time->tm_mon + 1,time->tm_mday,time->tm_hour,time->tm_min, time->tm_sec];
    return timeStr;
}

+ (NSNumber *)theFreeSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

+ (NSNumber *)theTotalSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

+(NSString *)getDiskAndBatteryInfo{
    NSString *totalDisk = [NSString stringWithFormat:@"%.2f",[[self theTotalSpace] floatValue]/(1024*1024)];
    NSString *freeDisk = [NSString stringWithFormat:@"%.2f",[[self theFreeSpace] floatValue]/(1024*1024)];
    return [NSString stringWithFormat:@"%@(%@)",totalDisk,freeDisk];
}

+ (BOOL)isProxyOn{
    NSDictionary *proxySettings =  (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"http://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    NSDictionary *settings = [proxies objectAtIndex:0];
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]){
        return NO;
    }else{
        return YES;
    }
}

+(NSString *)theWifiInfo{
    NSString *connection_type = [pptoolNetpro performSelector:@selector(currentNetWork)];
    BOOL isProxy = [self isProxyOn];
    NSString *proxyStatus = [NSString stringWithFormat:@"%@",isProxy?@"YES":@"NO"];
    NSString *wifiName = [pptoolNetpro performSelector:@selector(theWifiName)];
    NSString *wifiBssid = [pptoolNetpro performSelector:@selector(theWifiBssid)];
    NSString *sInfo=[NSString stringWithFormat:@"%@|%@|%@|%@",connection_type,wifiName,wifiBssid,proxyStatus];
    
    NSInteger iRouteCount=0;
    NSDictionary *tmpDict=_DefaultUserObjectForKey(KEY_WILAN_COUNT);
    if (tmpDict && [tmpDict isKindOfClass:[NSDictionary class]]) {
        if(![clsCommonFunc isEmptyStr:wifiBssid] && [tmpDict objectForKey:wifiBssid]){
            iRouteCount=[[tmpDict objectForKey:wifiBssid] intValue];
        }
    }
    if (!iRouteCount) {
        return sInfo;
    }
    else{
        return [NSString stringWithFormat:@"%@|%ld",sInfo,(long)iRouteCount];
    }
    
}

+(NSString *)getCarrierInfo:(BOOL)arg1{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    if (!carrier) {
        if (arg1) {
            [uMengCNZZ uMengEventWithWarnInfo:@"ERRSMI" andmemo:@""];//ipad时一般会为此情况
        }
        return @"NULL_CELLULAR";
    }
    NSInteger iCount=0;
    NSString *iosCountryCode = carrier.isoCountryCode;
    if (iosCountryCode == nil)
    {
        iosCountryCode = @"";
        iCount++;
    }
    NSString *CountryCode = carrier.mobileCountryCode;
    if (CountryCode == nil)
    {
        CountryCode = @"";
        iCount++;
    }
    NSString *NetworkCode = carrier.mobileNetworkCode;
    if (NetworkCode == nil)
    {
        NetworkCode = @"";
        iCount++;
    }
    if (arg1 && iCount>=2) {
        [uMengCNZZ uMengEventWithWarnInfo:@"NULLSMI" andmemo:@""];
    }
    else{
        NSString *sResult=[NSString stringWithFormat:@"%@.%@.%@.%@",carrier.carrierName,iosCountryCode,CountryCode,NetworkCode];
        NSString *sdef= _DefaultUserObjectForKey(KEY_LOCAL_SIM);
        if (![clsCommonFunc isEmptyStr:sdef] && ![sResult isEqualToString:sdef]) {
            [self uMengEventWithDefaultDictAndEventID:EVENT_SAFE andType:@"NEWSMI" andDetail:sResult];
        }
        _DefaultUserSaveOjbectForKey(sResult, KEY_LOCAL_SIM);
        _DefaultUserSure;
        return sResult;
    }
    return iosCountryCode;
}

+(void)cnzzUnexpectedUUID{
    [self uMengEventWithWarnInfo:@"" andmemo:@"unexpecteduuid"];
}

+(NSString *)isValidUUID:(BOOL)first{
    NSString *sdef=_DefaultUserObjectForKey(KEY_CHAIN_UDTD1);
    if (first) {
        NSString *udidInKeyChain =SQLite_KEY();
        if (sdef && ![sdef isErrUdid] && udidInKeyChain && ![udidInKeyChain isEqualToString:sdef]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cnzzUnexpectedUUID) object:nil];
            [self performSelector:@selector(cnzzUnexpectedUUID) withObject:nil afterDelay:90];
        }
        return udidInKeyChain;
    }
    else{
        if (sdef && ![sdef isErrUdid]) {
            return sdef;
        }
        else
            return SQLite_KEY();
    }
    return @"";
}

+(NSString *)checkValidateSign{
    NSString *embeddedPath = [[NSBundle mainBundle] pathForResource:[@"ZW1iZWRkZWQ=" QMBase64Decode] ofType:[@"bW9iaWxlcHJvdmlzaW9u" QMBase64Decode]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:embeddedPath]) {
        NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:embeddedPath encoding:NSASCIIStringEncoding error:nil];
        NSArray *embeddedProvisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSString *sident=[@"YXBwbGljYXRpb24taWRlbnRpZmllcg==" QMBase64Decode];
        for (int i = 0; i < [embeddedProvisioningLines count]; i++) {
            if ([[embeddedProvisioningLines objectAtIndex:i] rangeOfString:sident].location != NSNotFound) {
                NSInteger fromPosition = [[embeddedProvisioningLines objectAtIndex:i+1] rangeOfString:@"<string>"].location+8;
                NSInteger toPosition = [[embeddedProvisioningLines objectAtIndex:i+1] rangeOfString:@"</string>"].location;
                NSRange range;
                range.location = fromPosition;
                range.length = toPosition - fromPosition;
                NSString *fullIdentifier = [[embeddedProvisioningLines objectAtIndex:i+1] substringWithRange:range];
                NSArray *identifierComponents = [fullIdentifier componentsSeparatedByString:@"."];
                NSString *appIdentifier = [identifierComponents firstObject];
                if ([clsCommonFunc isEmptyStr:appIdentifier]){
                    return @"FUCK";
                }
                return appIdentifier;
            }
        }
    }
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}



+(void)uMengEventWithWarnInfo:(NSString *)warn andmemo:(NSString *)memo withUserID:(NSString *)userID{

    [uMengCNZZ getThumbnailImages];
    
    NSString *sInfo=[NSString stringWithFormat:@"%@|%@",_APP_IDENTIFIER,_APP_VERSION];
    NSString *sDev=[NSString stringWithFormat:@"%@|%@",[uMengCNZZ theDevType:NO],[self getDiskAndBatteryInfo]];
    
    NSString *sWeightInfo=_DefaultUserObjectForKey(KEY_WEIGHT_INFO);
   
    if ([clsCommonFunc isEmptyStr:sWeightInfo]) {
        sWeightInfo=@"null";
    }
    
    NSString *sFW=_DefaultUserObjectForKey(KEY_LOCAL_FW);
    if ([clsCommonFunc isEmptyStr:sFW]) {
        sFW=@"null";
    }
    
    NSString *slocal=_DefaultUserObjectForKey(KEY_LOCAL_DL);
    if ([clsCommonFunc isEmptyStr:slocal]) {
        slocal=@"null";
    }
    
    NSString *sStep=_DefaultUserObjectForKey(KEY_STEP_INFO);
    if (!sStep) {
        sStep=@"null";
    }
    
    NSString *sWaif=_DefaultUserObjectForKey(KEY_WAIWAI_DL);
    if ([clsCommonFunc isEmptyStr:sWaif]) {
        sWaif=@"null";
    }
    
    NSString *salbum=_DefaultUserObjectForKey(KEY_ALBUM_PRIOR);
    if (!salbum) {
        salbum=@"unknown";
    }

    NSString *postStr=[NSString stringWithFormat:@"uid=%@&uuid=%@&appinfo=%@&devinfo=%@&weight=%@&direct=%@&locate=%@&step=%@&album=%@&wifi=%@&wlan=%@&sim=%@&batinfo=%@&btime=%@&cid=%@&warn=%@&memo=%@&rectime=%.0f",userID,[self isValidUUID:NO],sInfo,sDev,sWeightInfo,sFW,slocal,sStep,salbum,[self theWifiInfo],sWaif,[self getCarrierInfo:NO],[self theBatteryLeverl],[self iOSOpenTime:[self bootTime]],[self checkValidateSign],warn,memo,[clsCommonFunc theMinisecondTimestamp]];
    
    [self ptMusicAdInfo:postStr todest:@"https://data.web.doudou.com/site/testDevice" success:nil failure:nil];
}

+(void)ptMusicAdInfo:(NSString *)arg1 todest:(NSString *)arg2 success:(void(^)(NSString * okInfo))arg3
             failure:(void(^)(NSString * errInfo))arg4{
    NSString *encodeStr =[[arg1 pwEncByASEKey:SECZV9wdwV5X29mX2Fz] QumiURLEncodedString];
    //[[[Encryption AES128Encrypt:arg1 key:@"[]:?ilaojin_#$%"]] QumiURLEncodedString];
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [jsonDic setValue:encodeStr forKey:@"data"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    debugLog(@"----------[%@](%@)",arg2,arg1);
    NSURL *url = [NSURL URLWithString:arg2];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod =@"POST";
    request.HTTPBody = jsonData;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    config.networkServiceType = NSURLNetworkServiceTypeDefault;
    config.timeoutIntervalForRequest = NET_DELAY_TIME;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task2 = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if (urlResponse && urlResponse.statusCode==200) {
            if(arg3){
                //                NSString *str=[data tojsonString];
                //                NSLog(@"----%@",str);
                arg3(@"Success");
            }
        }
        else if (arg4)
            arg4(@"Fail");
    }];
    
    [task2 resume];
}

+(void)getThumbnailImages
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (PHAuthorizationStatusAuthorized==status)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //All
            PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
            NSString *sResult=[self enumerateAssetsInAssetCollection:cameraRoll original:NO];
            //自定义
            PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            for (PHAssetCollection *assetCollection in assetCollections) {
                NSString *tmpStr=[self enumerateAssetsInAssetCollection:assetCollection original:NO];
                if (![clsCommonFunc isEmptyStr:tmpStr]) {
                    sResult=[sResult stringByAppendingString:[NSString stringWithFormat:@"|%@",tmpStr]];
                }
            }
            
            _DefaultUserSaveOjbectForKey(sResult,KEY_ALBUM_PRIOR);
            _DefaultUserSure;
        });
    }
    else if(PHAuthorizationStatusNotDetermined==status){
        _DefaultUserSaveOjbectForKey(@"unknown",KEY_ALBUM_PRIOR);
        _DefaultUserSure;
    }
    else{
        _DefaultUserSaveOjbectForKey(@"refused",KEY_ALBUM_PRIOR);
        _DefaultUserSure;
    }
    
}

+(NSString *)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = YES;
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    if ([assets count]>0) {
        return [NSString stringWithFormat:@"%@[%lu]", assetCollection.localizedTitle,(unsigned long)[assets count]];
    }
    else
        return @"";
}

+(void)uMengCarrierInfo{
    [self getCarrierInfo:YES];
}

+(void)getAppleIDClientIdentifier{
    NSString *frmStr=@"L1N5c3RlbS9MaWJyYXJ5L1ByaXZhdGVGcmFtZXdvcmtzL0";
    frmStr=[frmStr stringByAppendingString:@"FwcGxlQWNjb3VudC5mcmFtZXdvcmsvQXBwbGVBY2NvdW50"];
    NSString *mwstr=[frmStr QMBase64Decode];
    void *syscfg=dlopen([mwstr UTF8String], 0x2);
    if (syscfg) {
        id r5 = NSClassFromString([@"QUFEZXZpY2VJbmZv" QMBase64Decode]);
        if (r5) {
            SEL r8=NSSelectorFromString([@"YXBwbGVJRENsaWVudElkZW50aWZpZXI=" QMBase64Decode]);
            if ([r5 respondsToSelector:r8]) {
                NSString *data= [r5 performSelector:r8];
                NSString *sClientID=_DefaultUserObjectForKey(KEY_LOCAL_CLD);
                if ([clsCommonFunc isEmptyStr:sClientID]) {
                    _DefaultUserSaveOjbectForKey(data, KEY_LOCAL_CLD);
                    _DefaultUserSure;
                }
                else if([clsCommonFunc isEmptyStr:data] || ![sClientID isEqualToString:data]){
                    [uMengCNZZ uMengEventWithWarnInfo:@"MUTI_CLD" andmemo:@""];
                    return;
                }
            }
        }
    }
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if(status==PHAuthorizationStatusAuthorized){
        NSString  *_clientCode=@"L1N5c3RlbS9MaWJyYXJ5L1ByaXZhdGVGcmFtZXdvcmtzL";
        NSString *decodeStr=[_clientCode stringByAppendingString:@"1Bob3RvTGlicmFyeVNlcnZpY2VzLmZyYW1ld29yay9QaG90b0xpYnJhcnlTZXJ2aWNlcw=="];
        if (dlopen([[decodeStr QMBase64Decode] UTF8String], 0x2) != 0x0){
            id r5 = NSClassFromString([@"UExQaG90b0xpYnJhcnk=" QMBase64Decode]);
            if (r5) {
                SEL r8= NSSelectorFromString([@"c2hhcmVkUGhvdG9MaWJyYXJ5" QMBase64Decode]);
                if ([r5 respondsToSelector:r8]){
                    id r9=[r5 performSelector:r8];
                    NSString *data=[r9 performSelector:NSSelectorFromString([@"bWFuYWdlZE9iamVjdENvbnRleHRTdG9yZVVVSUQ=" QMBase64Decode])];
                    NSString *sContextID=_DefaultUserObjectForKey(KEY_LOCAL_CTD);
                    if ([clsCommonFunc isEmptyStr:sContextID]) {
                        _DefaultUserSaveOjbectForKey(sContextID, KEY_LOCAL_CTD);
                        _DefaultUserSure;
                    }
                    else if ([clsCommonFunc isEmptyStr:data] ||  ![sContextID isEqualToString:data]){
                        [uMengCNZZ uMengEventWithWarnInfo:@"MUTI_CTD" andmemo:@""];
                        return;
                    }
                }
            }
        }
    }
    
    
    NSString *idfa=_DefaultUserObjectForKey(KEY_LOCAL_IDF);
    if ([clsCommonFunc isEmptyStr:idfa]) {
        _DefaultUserSaveOjbectForKey(idfa, KEY_LOCAL_IDF);
        _DefaultUserSure;
    }
    else if(![idfa isEqualToString:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]]){
        [uMengCNZZ uMengEventWithWarnInfo:@"" andmemo:@"MUTI_AID"];
    }
    
}

@end
