//
//  ZDNetInfo.m
//  paopaoread
//
//  Created by 七七 on 2017/12/19.
//  Copyright © 2017年 paopaoread. All rights reserved.
//

#import "pptoolNetpro.h"
#include <sys/types.h>
#import "QMReachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <net/if.h>

//#import "CXScanAddress.h"
//#import "CXIPDetector.h"
//#import "CXScanLAN.h"

//#define IOS_CELLULAR    @"pdp_ip0"
//#define IOS_WIFI        @"en0"
//#define IP_ADDR_IPv4    @"ipv4"
//#define IP_ADDR_IPv6    @"ipv6"


@implementation pptoolNetpro

+(NSString *)theLocalMk{
    NSMutableDictionary *localInfoDic=[NSMutableDictionary dictionaryWithDictionary: [[NSUserDefaults standardUserDefaults] objectForKey:@"bendiApmk_Dic"]];
    if (localInfoDic && [localInfoDic objectForKey:@"localmk"]) {
        return [localInfoDic objectForKey:@"localmk"];
    }
    else
        return @"";
}

+(BOOL)isNetworkAvailable{
    return [QMReachability networkAvailable];
}

+ (NSString *)currentNetWork
{
    NSString *connectStr = nil;
    
    int networkState = [self connectedToNetwork];
    
    switch (networkState)
    {
        case 0:
        {
            //  isExistenceNetwork = NO;
            connectStr = @"";
        }
            break;
        case 1:
        {
            //   isExistenceNetwork = YES;
            connectStr = @"WWAN";
        }
            break;
        case 2:
        {
            //   isExistenceNetwork = YES;
            connectStr = @"wifi";
        }
            break;
        default:
            break;
    }
    return connectStr;
}

//检测当前网络连接的状况，如果网络不畅通，那么就返回没有网络
+ (int) connectedToNetwork
{
    int kind;
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags)
    {
        kind = 0;
    }
    else
    {
        //根据获得的连接标志进行判断
        BOOL isReachable = flags & kSCNetworkFlagsReachable;
        BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
        
        if((isReachable && !needsConnection)==YES)
        {
            if((flags& kSCNetworkReachabilityFlagsIsWWAN)==kSCNetworkReachabilityFlagsIsWWAN)
            {
                kind = 1;//wan
            }
            else
            {
                kind = 2;//wifi
            }
        }
        else
        {
            kind = 0;
        }
    }
    return kind;
}

+ (NSString *)theNetworkLx{
    NSString *netconnType = @"errNet";
    QMReachability *reach = [QMReachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:// 没有网络
        {
            netconnType = @"noNet";
        }
            break;

        case ReachableViaWiFi:// Wifi
        {
            netconnType = @"wifi";
        }
            break;

        case ReachableViaWWAN:// 手机自带网络
        {
            netconnType = @"4G";
        }
            break;

        default:
            break;
    }
    return netconnType;
}

+ (NSString *)theWifiName
{
    NSString *wifiName = @"nofound";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiName = [dict valueForKey:@"SSID"];
        }
        CFRelease(myArray);
    }
    return wifiName;
}

+ (NSString *)theWifiBssid
{
    NSString *wifiBssid = @"nofound";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiBssid = [dict valueForKey:@"BSSID"];
        }
        CFRelease(myArray);
    }
    return wifiBssid;
}

+ (NSDictionary *)theApDic
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    NSMutableDictionary *ipTempDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    
    NSString *simcardlocalIp = @"";
    NSString *agentlocalIp = @"";
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)//
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"] || [name isEqualToString:@"en1"] || [name isEqualToString:@"en2"])
                {
                    NSString *wifilocalIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                    [ipTempDic setObject:wifilocalIP forKey:@"wifilocalIP"];
                }
                else if ([name isEqualToString:@"pdp_ip0"] || [name isEqualToString:@"pdp_ip1"] || [name isEqualToString:@"pdp_ip2"])
                {
                    simcardlocalIp = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                    [ipTempDic setObject:simcardlocalIp forKey:@"simcardlocalIp"];
                }
                else if ([name isEqualToString:@"ppp0"] || [name isEqualToString:@"ppp01"] || [name isEqualToString:@"ppp02"])
                {
                    agentlocalIp = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                    [ipTempDic setObject:agentlocalIp forKey:@"agentlocalIp"];
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return ipTempDic;
}

+ (BOOL)isProxyOn{
    //可以检测到proxy及vpn
    NSDictionary *proxySettings =  (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"http://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    NSDictionary *settings = [proxies objectAtIndex:0];
    
    CFRelease((__bridge CFDictionaryRef)(proxySettings));
    CFRelease((__bridge CFArrayRef)(proxies));
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]){
        return NO;
    }
    else
        return YES;
}


+(NSDictionary *)getWifiInfo{
    //获取wifi的名字
    NSString *wifiName = [[self theWifiName] UTF8_URL];
    NSString *wifiBssid = [self theWifiBssid];
    NSString *wifilocalIP = @"";
    NSString *simcardlocalIp = @"";
    NSString *agentlocalIp = @"";
    NSDictionary *threeIpDic = [self theApDic];
    if (threeIpDic) {
        wifilocalIP = [threeIpDic objectForKey:@"wifilocalIP"];
        if (wifilocalIP == nil) {
            wifilocalIP = @"notfound";
        }
        simcardlocalIp = [threeIpDic objectForKey:@"simcardlocalIp"];
        if (simcardlocalIp == nil) {
            simcardlocalIp = @"notfound";
        }
        agentlocalIp = [threeIpDic objectForKey:@"agentlocalIp"];
        if (agentlocalIp == nil) {
            agentlocalIp = @"notfound";
        }
    }
    
    NSString *macid = [self theLocalMk];
    NSString *net_type = [self theNetworkLx];
    NSString *connection_type = [self currentNetWork];   //用户使用的网络wifi/4g
    BOOL isProxy = [self isProxyOn];
    NSString *proxyStatus = [NSString stringWithFormat:@"%d",isProxy];
    
    NSDictionary *bkDIC=[NSDictionary dictionaryWithObjectsAndKeys:wifiName,@"wifiName",wifiBssid,@"wifiBssid",wifilocalIP,@"wifilocalIP",simcardlocalIp,@"simcardlocalIp",agentlocalIp,@"agentlocalIp",macid,@"macid",net_type,@"net_type",connection_type,@"connection_type",proxyStatus,@"proxyStatus", nil];
    return bkDIC;
}


@end
