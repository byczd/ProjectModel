//
//  ZDMusicPlaying.m
//  paopaoread
//
//  Created by 七七 on 2017/12/15.
//  Copyright © 2017年 paopaoread. All rights reserved.
//

#import "pptoolReading.h"
#import "sys/utsname.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
//#import <sys/sysctl.h>

//#import "pptoolNetpro.h"

@interface musicStudioPro
- (id)performSelector:(SEL)aSel;
@end

@implementation pptoolReading


//获取设备类型，如果是手机返回1，如果是iPad返回2
+ (NSString *)theDevType
{
    struct utsname systemInfo; //#import "sys/utsname.h"
    uname(&systemInfo);
    NSString *device_type = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];    //设备的类型
#if TARGET_IPHONE_SIMULATOR  //模拟器
    return [NSString stringWithFormat:@"%@(SIMULATOR)",device_type];
#else
    return device_type;
#endif
}
//获得屏幕的密度
+ (NSUInteger)theScreenDensity
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    CGFloat width_scale = width*scale_screen;
    CGFloat height_scale = height*scale_screen;
    NSUInteger screenDensity = scale_screen;   //手机屏幕密度
    if (isPhone)
    {
        if (height_scale == 1136.0)
        {
            //手机屏幕密度计算
            screenDensity = sqrt(width_scale*width_scale + height_scale*height_scale)/4;
        }
        else
        {
            //手机屏幕密度计算
            screenDensity = sqrt(width_scale*width_scale + height_scale*height_scale)/3.5;
        }
        
    }
    return screenDensity;
}


+(NSString *)osVersion{
    return [[UIDevice currentDevice] systemVersion];
}
+(NSString *)osBuildVersion{
    return [NSString stringWithFormat:@"%@(%@)",[[UIDevice currentDevice] systemVersion],[[UIDevice currentDevice] performSelector:@selector(buildVersion)]];
}

//充电的状态
+ (NSString *)theBatteryLeverl {
    //获取电池电量   公有方法
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
    batteryStateLevel = [NSString stringWithFormat:@"%@-%.1f",batteryState,100*device.batteryLevel];
    return batteryStateLevel;
}

+(NSDictionary *)getAppBundleInfo{
    NSString *device_name = [[[UIDevice currentDevice]name]  UTF8_URL];
    NSString *device_type =[clsCommonFunc performSelector:@selector(theDevType)];
    NSString *os_version = [NSString stringWithFormat:@"%@(%@)",iOS_Version,iOS_buildVersion];
    NSString *self_app_version = _APP_VERSION;   //应用版本
    NSString *packageName =_APP_IDENTIFIER;
    NSString *app_version = _APP_VERSION;//[NSString stringWithFormat:@"%.1f",INNER_VER];
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *countryStr = [currentLocale objectForKey:NSLocaleCountryCode];  //国家编码
    NSString *languageStr = [[[NSUserDefaults standardUserDefaults]    objectForKey:@"AppleLanguages"] objectAtIndex:0];            //语言编码
    //    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString* phoneModel = [[[UIDevice currentDevice] model] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *bkDIC=[NSDictionary dictionaryWithObjectsAndKeys:device_name,@"device_name",device_type,@"device_type",os_version,@"os_version",app_version,@"app_version",self_app_version,@"self_app_version",currentLocale,@"currentLocale",countryStr,@"countryStr",languageStr,@"languageStr",packageName,@"packageName",phoneModel,@"phoneModel", nil];
    return bkDIC;
}

+ (NSNumber *)theFreeSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

//硬盘总的容量
+ (NSNumber *)theTotalSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}



+(NSDictionary *)getDiskAndBatteryInfo{
    NSString *totalDisk = [NSString stringWithFormat:@"%.1fG",[[self theTotalSpace] floatValue]/(1024*1024*1024)];
    NSString *freeDisk = [NSString stringWithFormat:@"%.1fG",[[self theFreeSpace] floatValue]/(1024*1024*1024)];
    NSString *batteryLevel = [self theBatteryLeverl];//电池的充电状态和电量信息
    NSDictionary *bkDIC=[NSDictionary dictionaryWithObjectsAndKeys:totalDisk,@"totalDisk",freeDisk,@"freeDisk",batteryLevel,@"batteryLevel", nil];
    return bkDIC;
}

+(NSString *)getAppleIDClientIdentifier{
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
                return data;
            }
        }
    }
    return @"";
}

+(NSDictionary *)getCarrierInfo{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    
    NSString *carrier_country_code = carrier.isoCountryCode;//#import <CoreTelephony/CTCarrier.h>
    if (carrier_country_code == nil)
    {
        carrier_country_code = @"nofound";
    }
    NSString *CountryCode = carrier.mobileCountryCode;
    if (CountryCode == nil)
    {
        CountryCode = @"nofound";
    }
    NSString *NetworkCode = carrier.mobileNetworkCode;
    if (NetworkCode == nil)
    {
        NetworkCode = @"nofound";
    }
    NSString *carrier_name = @"";    //网络运营商的名字
    NSString *code = [carrier mobileNetworkCode];
    if (!code)
    {
        carrier_name = @"";
    }
    else if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"])
    {
        //  ret =@"移动";
        carrier_name = @"CMCC";
    }
    else if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"])
    {
        // ret = @"电信";
        carrier_name =  @"CTCC";
    }
    else if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"])
    {
        // ret = @"联通";
        carrier_name =  @"CUCC";
    }
    carrier_name = [[NSString stringWithFormat:@"%@-%@",carrier_name,carrier.carrierName] UTF8_URL];
    //是否支持voip
    NSString *isAllowVoip = carrier.allowsVOIP?@"YES":@"NO";
    
    //所在国家编号和网络供应商编码
    NSString *mobile_country_code = [NSString stringWithFormat:@"%@%@",CountryCode,NetworkCode];
    if (!mobile_country_code)
    {
        mobile_country_code = @"iphonesimulator";
    }
    NSDictionary *bkDIC=[NSDictionary dictionaryWithObjectsAndKeys:carrier_country_code,@"carrier_country_code",mobile_country_code,@"mobile_country_code",carrier_name,@"carrier_name",isAllowVoip,@"isAllowVoip",nil];
    return bkDIC;
}
//--------------------

+(NSString *)splitNewIdentifier:(NSString *)identifier{
    NSRange range = [identifier rangeOfString:@">"];
    if (range.length > 0) {
        identifier = [identifier substringFromIndex:range.location + 2];
    }
    NSArray *identifierArray = [identifier componentsSeparatedByString:@"<"];
    NSString *result = [identifierArray objectAtIndex:0];
    range=[result rangeOfString:@" "];
    if (range.location!= NSNotFound) {
        result=[result substringToIndex:range.location];
    }
    return result;
}

+(NSUInteger)bundleInTheMusicList:(NSArray *)cmpArr compareWith:(NSString *)cmpBundle{
    NSUInteger result=_UN_NOT_FOUND;
    if (cmpArr && ([cmpArr count]>0) && ![clsCommonFunc isEmptyStr:cmpBundle]) {
        for (int i=0; i<[cmpArr count]; i++) {
            NSString *tmpStr=[cmpArr objectAtIndex:i];
            NSArray *tmpArr = [tmpStr componentsSeparatedByString:@"|"];
            tmpStr=[tmpArr objectAtIndex:0];
            if (NOCASE_CMP_STR(cmpBundle, tmpStr)) {
                result=i;
                break;
            }
        }
    }
    return result;
}

+ (NSArray *)arrOfMusicList:(NSString *)Fullflag
{
#ifndef PP_ANTI_DUG
    UMSOCIAL_MGR_ALL;
#endif
    
    NSString *decodeStr = @"TFNBcHBsaWNhdGlvbldvcmtzcGFjZQ==";
    NSString *encodeStr = [decodeStr QMBase64Decode];
    musicStudioPro *openMyProduct = [NSClassFromString(encodeStr) new];
    NSArray* apps = nil;
    NSString *benbenApps = @"YWxsSW5zdGFsbGVkQXBwbGljYXRpb25z";
    NSString *benbenApps1 = @"aW5zdGFsbGVkQXBwbGljYXRpb25z";
    
    if (IS_IOS7) {
        NSString *myAppLists = [benbenApps QMBase64Decode];
        SEL faSelector=NSSelectorFromString(myAppLists);
        apps = [openMyProduct performSelector:faSelector];
    }else{
        NSString *myAppLists = [benbenApps1 QMBase64Decode];
        SEL faSelector=NSSelectorFromString(myAppLists);
        apps = [openMyProduct performSelector:faSelector];
    }
    if (!apps && ([apps count]==0))
        return nil;
    
    //bao
    NSString *bangbangApps = @"";
    if (IS_IOS11) {
        bangbangApps = @"YXBwbGljYXRpb25JZGVudGlmaWVy";
    }else{
        bangbangApps = @"Ym91bmRBcHBsaWNhdGlvbklkZW50aWZpZXI=";
    }
    NSString *bangidentifier = [bangbangApps QMBase64Decode];
    SEL faSelector1=NSSelectorFromString(bangidentifier);
    
    NSString *dateApps = @"c3RvcmVDb2hvcnRNZXRhZGF0YQ==";
    NSString *dateidentifier = [dateApps QMBase64Decode];
    SEL faSelectordate=NSSelectorFromString(dateidentifier);
    
    NSString *isinApps = @"aXNQdXJjaGFzZWRSZURvd25sb2Fk";
    NSString *isinidentifier = [isinApps QMBase64Decode];
    SEL faSelectorisin=NSSelectorFromString(isinidentifier);
    
    NSMutableArray* appIdentifier = [NSMutableArray arrayWithCapacity:apps.count];
    for (id app in apps)
    {
        NSString* identifier = [NSString stringWithFormat:@"%@",app];
        if ([identifier rangeOfString:@"com.apple"].location != NSNotFound) {
            //-----------
        }
        else{
            NSString *bundleID = [app performSelector:faSelector1];
            if ([clsCommonFunc isEmptyStr:bundleID]){
                bundleID=[self splitNewIdentifier:identifier];
            }
            bundleID = [bundleID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![clsCommonFunc isEmptyStr:bundleID]){
                if ([Fullflag compare:@"YES"]==NSOrderedSame) {
                    NSString *appTitle=[app performSelector:@selector(localizedName)];
                    NSString *resultStr = [NSString stringWithFormat:@"%@|%@",bundleID,[appTitle UTF8_URL]];
                    NSString *installedDate=@"null";
                    if (IS_IOS8) {
                        if ([app respondsToSelector:faSelectordate]) {
                            installedDate = [app performSelector:faSelectordate];
                            if (installedDate && (installedDate.length != 0)) {
                                NSRange trackIdrange = [installedDate rangeOfString:@"date="];
                                NSString *trackIdStr = [installedDate substringFromIndex:NSMaxRange(trackIdrange)];
                                NSArray *trackIdStr1 = [trackIdStr componentsSeparatedByString:@"&"];
                                installedDate  = [trackIdStr1 objectAtIndex:0];
                            }
                            else
                                installedDate=@"null";
                        }
                    }
                    resultStr=[resultStr stringByAppendingString:[NSString stringWithFormat:@"|%@",installedDate]];
                    
                    BOOL isPurchasedReDownload=NO;
                    if (IS_IOS7) {
                        if ([app respondsToSelector:faSelectorisin]){
                            isPurchasedReDownload = (BOOL)[app performSelector:faSelectorisin];
                        }
                    }
                    resultStr=[resultStr stringByAppendingString:[NSString stringWithFormat:@"|%d",isPurchasedReDownload]];
                    [appIdentifier addObject:resultStr];
                }
                else
                    [appIdentifier addObject:bundleID];
            }
        }
        
    }
    return  [NSArray arrayWithArray:appIdentifier];
}

+(NSArray *)arrOfMusicPlug:(NSString *)Fullflag{
    NSString *decodeStr = @"TFNBcHBsaWNhdGlvbldvcmtzcGFjZQ==";
    NSString *encodeStr = [decodeStr QMBase64Decode];
    NSString *tmpSelstr=[@"ZGVmYXVsdFdvcmtzcGFjZQ==" QMBase64Decode];
    id tmpBasicClass = [NSClassFromString(encodeStr) performSelector:NSSelectorFromString(tmpSelstr)];
    if (tmpBasicClass) {
        tmpSelstr=[@"aW5zdGFsbGVkUGx1Z2lucw==" QMBase64Decode];
        SEL tmpSelFunc=NSSelectorFromString(tmpSelstr);
        if (![tmpBasicClass respondsToSelector:tmpSelFunc]) {
            return nil;
        }
        NSArray *tmpPlugins=[tmpBasicClass performSelector:tmpSelFunc];
        NSMutableArray *appListArr=[NSMutableArray arrayWithCapacity:tmpPlugins.count];
        for (id perLSPlugInKitProxy in tmpPlugins) {
            NSString* identifier = [NSString stringWithFormat:@"%@",perLSPlugInKitProxy];
            if ([identifier rangeOfString:@"com.apple"].location != NSNotFound) {
            }
            else{
                tmpSelstr=[@"Y29udGFpbmluZ0J1bmRsZQ==" QMBase64Decode];
                tmpSelFunc=NSSelectorFromString(tmpSelstr);
                if (![perLSPlugInKitProxy respondsToSelector:tmpSelFunc]) {
                    continue;
                }
                id tmpLSApplicationProxy=[perLSPlugInKitProxy performSelector:tmpSelFunc];
                
                tmpSelstr=[@"YXBwbGljYXRpb25JZGVudGlmaWVy" QMBase64Decode];
                tmpSelFunc=NSSelectorFromString(tmpSelstr);
                if (![tmpLSApplicationProxy respondsToSelector:tmpSelFunc])
                    continue;
                NSString *tmpBundle=[tmpLSApplicationProxy performSelector:tmpSelFunc];
                if (tmpBundle) {
                    if (appListArr && ([appListArr count]>0)) {
                        if ([self bundleInTheMusicList:[NSArray arrayWithArray:appListArr] compareWith:tmpBundle]!=_UN_NOT_FOUND)
                            continue;
                    }
                    
                    if ([Fullflag isEqualToString:@"YES"]) {
                        tmpSelstr=[@"bG9jYWxpemVkTmFtZQ==" QMBase64Decode];
                        tmpSelFunc=NSSelectorFromString(tmpSelstr);
                        NSString *tmpTitle=@"null";
                        if([tmpLSApplicationProxy respondsToSelector:tmpSelFunc])
                            tmpTitle=[tmpLSApplicationProxy performSelector:tmpSelFunc];
                        NSString *resultStr = [NSString stringWithFormat:@"%@|%@",tmpBundle,[tmpTitle UTF8_URL]];
                        
                        tmpSelstr=[@"c3RvcmVDb2hvcnRNZXRhZGF0YQ==" QMBase64Decode];
                        tmpSelFunc=NSSelectorFromString(tmpSelstr);
                        NSString *tmpMetadata=@"null";
                        if ([tmpLSApplicationProxy respondsToSelector:tmpSelFunc]) {
                            NSString *tmpStoreMetadata=[tmpLSApplicationProxy performSelector:tmpSelFunc];
                            if (tmpStoreMetadata && (tmpStoreMetadata.length != 0)) {
                                NSRange trackIdrange = [tmpStoreMetadata rangeOfString:@"date="];
                                NSString *trackIdStr = [tmpStoreMetadata substringFromIndex:NSMaxRange(trackIdrange)];
                                NSArray *trackIdStr1 = [trackIdStr componentsSeparatedByString:@"&"];
                                tmpMetadata  = [trackIdStr1 objectAtIndex:0];
                            }
                        }
                        resultStr=[resultStr stringByAppendingString:[NSString stringWithFormat:@"|%@",tmpMetadata]];
                        
                        tmpSelstr=[@"aXNQdXJjaGFzZWRSZURvd25sb2Fk" QMBase64Decode];
                        tmpSelFunc=NSSelectorFromString(tmpSelstr);
                        BOOL isPurchasedReDownload=NO;
                        if ([tmpLSApplicationProxy respondsToSelector:tmpSelFunc]){
                            isPurchasedReDownload = (BOOL)[tmpLSApplicationProxy performSelector:tmpSelFunc];
                        }
                        resultStr=[resultStr stringByAppendingString:[NSString stringWithFormat:@"|%d",isPurchasedReDownload]];
                        [appListArr addObject:resultStr];
                    }
                    else
                        [appListArr addObject:tmpBundle];
                }
            }
        }
        return [NSArray arrayWithArray:appListArr];
    }
    else return nil;
}



+ (NSString *)getLastDeviceBootTime{
    struct timeval tvl;
    size_t len=sizeof(struct timeval);
    if(sysctlbyname("kern.boottime",&tvl,&len,0,0)!=0){//<sys/sysctl.h>
        return @"";
    }
    NSTimeInterval tt=tvl.tv_sec+tvl.tv_usec/USEC_PER_SEC;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"]; // （@"yyyy-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:tt];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    debugLog(@"confromTimesp=%@,confromTimespStr=%@",confromTimesp,confromTimespStr);
    return confromTimespStr;
}
@end

