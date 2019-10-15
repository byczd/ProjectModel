//
//  simpleSQL.m
//  paopaoread
//
//  Created by 七七 on 2017/12/19.
//  Copyright © 2017年 paopaoread. All rights reserved.
//

#import "simpleSQL.h"

@implementation simpleSQL



+(BOOL)storePassword:(NSString *)password forServiceName:(NSString *)serviceName andAccount:(NSString *)userName{
    BOOL result=NO;
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:serviceName withAccount:userName andDelFlag:NO accessGroup:nil];// 1
    if (keychain) {
        result=[keychain setObject:password forKey:(__bridge id)(kSecValueData)];// 3
    }
    return result;
}

+(NSString *)getPassWordforServiceName:(NSString *)serviceName andAccount:(NSString *)userName{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:serviceName withAccount:userName andDelFlag:NO accessGroup:nil];// 通过同样的标志创建keychain
    NSString *password=@"";
    if (keychain){
        password = [keychain objectForKey:(__bridge id)(kSecValueData)];
    }
    if (!password) {//最好不要为nil，否则有可能dictionary中赋值时会出错
        password=@"";
    }
    return password;
}

+(void)deleteService:(NSString *)serviceName andAccount:(NSString *)userName{
    [[KeychainItemWrapper alloc] initWithIdentifier:serviceName withAccount:userName andDelFlag:YES accessGroup:nil];
}

+(NSString *)theIdfa{
 return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

+(NSString *)theIdfv{
    return [[[UIDevice currentDevice]identifierForVendor] UUIDString];
}


+ (BOOL)isAdStateEnabled{
    //是否限制广告追踪(isAdvertisingTrackingEnabled,限制追踪值为NO=0，不限制追踪值为YES=1)
    return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
}


@end
