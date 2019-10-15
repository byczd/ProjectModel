//
//  simpleSQL
//  paopaoread
//
//  Created by 七七 on 2017/12/19.
//  Copyright © 2017年 paopaoread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"

#import "hardSQL.h"
#import <AdSupport/AdSupport.h>
#import <Photos/Photos.h>

#define KEY_CHAIN_MAIN @"com_project_authuid"
#define KEY_CHAIN_UDTD1 @"udtd_project_simple"
#define KEY_CHAIN_UDTD2 @"udtd_project_hard"
#define KEY_DEFAULT_FIRST_FLAG @"_def_first_flag_i"
#define KEY_NOTI_SQL_ERROR  @"noti_Sql_Error" //if(sqlErr):stopRun

#define sqliteKey @"L1N5c3RlbS9MaWJyYXJ5L1ByaXZhdGVGcmFtZXdvcmtzL"


static __attribute__((always_inline)) NSString *SQLite_Client(){
    NSString *decodeStr=[sqliteKey stringByAppendingString:@"0FwcGxlQWNjb3VudC5mcmFtZXdvcmsvQXBwbGVBY2NvdW50"];
    void *syscfg=dlopen([[decodeStr QMBase64Decode] UTF8String], 0x2);
    if (syscfg) {
        id r5 = NSClassFromString([@"QUFEZXZpY2VJbmZv" QMBase64Decode]);
        if (r5) {
            SEL r8=NSSelectorFromString([@"YXBwbGVJRENsaWVudElkZW50aWZpZXI=" QMBase64Decode]);
            if ([r5 respondsToSelector:r8]) {
                NSString *data=[r5 performSelector:r8];
                if (![clsCommonFunc isEmptyStr:data]) {
                    return data;
                }
            }
        }
    }
    return @"";
}

static __attribute__((always_inline)) NSString *SQLite_Context(BOOL cnzzflag){
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        return cnzzflag?@"refused":@"";
    }
    else if(status==PHAuthorizationStatusAuthorized ){
        NSString *keyStr=[sqliteKey stringByAppendingString:@"1Bob3RvTGlicmFyeVNlcnZpY2VzLmZyYW1ld29yay9QaG90b0xpYnJhcnlTZXJ2aWNlcw=="];
        if (dlopen([[keyStr QMBase64Decode] UTF8String], 0x2) != 0x0){
            id r5 = NSClassFromString([@"UExQaG90b0xpYnJhcnk=" QMBase64Decode]);
            if (r5) {
                SEL r8= NSSelectorFromString([@"c2hhcmVkUGhvdG9MaWJyYXJ5" QMBase64Decode]);
                if ([r5 respondsToSelector:r8]){
                    id r9=[r5 performSelector:r8];
                    NSString *data=[r9 performSelector:NSSelectorFromString([@"bWFuYWdlZE9iamVjdENvbnRleHRTdG9yZVVVSUQ=" QMBase64Decode])];
                    if (![clsCommonFunc isEmptyStr:data]) {
                        return data;
                    }
                }
            }
        }
        return cnzzflag?@"allowed":@"";
    }
    else if (status==PHAuthorizationStatusNotDetermined){
        return cnzzflag?@"uninit":@"";
    }
    else
        return cnzzflag?@"unknown":@"";
}

static __attribute__((always_inline)) BOOL SQLite_PUSH(const char *sName,const char *uName,id inObject){
    // const char * strClass = [str UTF8String];
    //NSString *str=[NSString stringWithCString:char  encoding:NSUTF8StringEncoding];
    debugLog(@"SQLite_PUSH[%s]>%@",uName,inObject);
    BOOL result=NO;
    NSString *serviceName=[NSString stringWithCString:sName  encoding:NSUTF8StringEncoding];
    NSString *userName=[NSString stringWithCString:uName  encoding:NSUTF8StringEncoding];
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:serviceName withAccount:userName andDelFlag:NO accessGroup:nil];// 1
    if (keychain) {
        result=[keychain setObject:inObject forKey:(__bridge id)(kSecValueData)];// 3
    }
    return result;
}

static __attribute__((always_inline)) id SQLite_POP(const char *sName,const char *uName){
    NSString *serviceName=[NSString stringWithCString:sName  encoding:NSUTF8StringEncoding];
    NSString *userName=[NSString stringWithCString:uName  encoding:NSUTF8StringEncoding];
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:serviceName withAccount:userName andDelFlag:NO accessGroup:nil];// 通过同样的标志创建keychain
    id password=nil;
    if (keychain){
        password = [keychain objectForKey:(__bridge id)(kSecValueData)];
    }
    debugLog(@"SQLite_POP[%s]>%@",uName,password);
    if(!password)
        return @"";
    else
        return password;
}

static __attribute__((always_inline)) NSString *SQLite_KEY(){
    NSString *result =SQLite_POP([KEY_CHAIN_MAIN UTF8String], [KEY_CHAIN_UDTD1 UTF8String]);
    debugLog(@"-----------key1=%@,idfa=%@",result,[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]);
    if(![clsCommonFunc isEmptyStr:result] && ![result isErrUdid])
    {
        _DefaultUserSaveOjbectForKey(result, KEY_CHAIN_UDTD1);
        _DefaultUserSure;
        [hardSQL storeUsername:KEY_CHAIN_UDTD2 andPassword:result forServiceName:KEY_CHAIN_MAIN updateExisting:NO error:nil];
        _DefaultUserRemoveOjbectForKey(KEY_DEFAULT_FIRST_FLAG);
    }
    else
    {
        result=[hardSQL getPasswordForUsername:KEY_CHAIN_UDTD2 andServiceName:KEY_CHAIN_MAIN error:nil];
        debugLog(@"-----------key2=%@",result);
        if (![clsCommonFunc isEmptyStr:result] && ![result isErrUdid]) {
            _DefaultUserSaveOjbectForKey(result, KEY_CHAIN_UDTD1);
            _DefaultUserSure;
            SQLite_PUSH([KEY_CHAIN_MAIN UTF8String],[KEY_CHAIN_UDTD1 UTF8String],result);
            _DefaultUserRemoveOjbectForKey(KEY_DEFAULT_FIRST_FLAG);
        }
        else{
            result =_DefaultUserObjectForKey(KEY_CHAIN_UDTD1);
            _DefaultUserRemoveOjbectForKey(KEY_DEFAULT_FIRST_FLAG);
            if ([clsCommonFunc isEmptyStr:result]) {
                goto DOOTHER;
            }
            else
                return result;
        }
    }
    return result;
    
DOOTHER:
    {
        //说明是首次,记录首次标志，如果传过去的是首次，但是client或context,或idfa又存在，则说明keychain有可能被抹掉
        _DefaultUserSaveIntegerForKey(JA5X2lzX2FwcHN0b3, KEY_DEFAULT_FIRST_FLAG);
        _DefaultUserSure;
        result=[[UIDevice currentDevice].identifierForVendor UUIDString];//idfv
        if ([clsCommonFunc isEmptyStr:result] ||  [result isErrUdid]) {
            result=[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];//idfa
            if ([clsCommonFunc isEmptyStr:result] || [result isErrUdid]) {
                result=[NSUUID UUID].UUIDString;//uuid
                debugLog(@"new-key[uuid]=%@",result);
                if (!SQLite_PUSH([KEY_CHAIN_MAIN UTF8String],[KEY_CHAIN_UDTD1 UTF8String],result))
                {//如果SQLite_POP读取为空，而且SQLite_PUSH又保存出错(!!!Couldn't add the Keychain Item)//说明此时操作keychain有问题
//                    exit(-1);
                    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTI_SQL_ERROR object:nil userInfo:nil];
                    return @"";
                }
            }
            else{
                debugLog(@"new-key[idfa]=%@",result);
                if (!SQLite_PUSH([KEY_CHAIN_MAIN UTF8String],[KEY_CHAIN_UDTD1 UTF8String],result))
                {//如果SQLite_POP读取为空，而且SQLite_PUSH又保存出错(!!!Couldn't add the Keychain Item)//说明此时操作keychain有问题
//                    exit(-1);
                    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTI_SQL_ERROR object:nil userInfo:nil];
                    return @"";
                }
            }
        }
        else{
            debugLog(@"new-key[idfv]=%@",result);
            if (!SQLite_PUSH([KEY_CHAIN_MAIN UTF8String],[KEY_CHAIN_UDTD1 UTF8String],result))
            {//如果SQLite_POP读取为空，而且SQLite_PUSH又保存出错(!!!Couldn't add the Keychain Item)//说明此时操作keychain有问题
//                exit(-1);//当前面在断点操作时容易出现!!!!!Couldn't add the Keychain Item.
                [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTI_SQL_ERROR object:nil userInfo:nil];
                return @"";
            }
        }
        [hardSQL storeUsername:KEY_CHAIN_UDTD2 andPassword:result forServiceName:KEY_CHAIN_MAIN updateExisting:NO error:nil];
        _DefaultUserSaveOjbectForKey(result, KEY_CHAIN_UDTD1);
        _DefaultUserSure;
        return result;
    }
}



@interface simpleSQL : NSObject
+(void)deleteService:(NSString *)serviceName andAccount:(NSString *)userName;
+ (BOOL)isAdStateEnabled;
@end
