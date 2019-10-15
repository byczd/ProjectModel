//
//  PSWebSocketDevice.m
//  paopaoread
//
//  Created by 七七 on 2018/8/31.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#import "PSWebSocketDevice.h"

#define PSWEBHIDDENFILES     [NSArray arrayWithObjects:@"/Library/MobileSubstrate/MobileSubstrate.dylib",@"/bin/bash",@"/etc/apt",@"/usr/sbin/sshd",@"/usr/bin/sshd",@"/usr/libexec/sftp-server",@"/Applications/Cydia.app",@"/Library/MobileSubstrate/DynamicLibraries/AppSync.dylib",@"/Library/MobileSubstrate/DynamicLibraries/AppList.dylib",@"/Library/MobileSubstrate/DynamicLibraries/RocketBootstrap.dylib",@"/private/var/tmp/cydia.log",  @"/etc/ssh/ssh_config", @"/var/lib/cydia/firmware.ver",  nil]
//#define PSWEBPACKAGEURL    @"cydia://package/com.fake.package"

@implementation PSWebSocketDevice

//1-0
static __attribute__((always_inline)) int PSWebjailEnv()
{
    char *env = getenv("DYLD_INSERT_LIBRARIES");
//    debugLog(@"env=[%s]",env);
    if (env != NULL) {//越狱设备中，未被注入返回结果是(null) ，如被注入了则返回为：/Library/MobileSubstrate/MobileSubstrate.dylib，
        return arc4random()%10+JA5X2lzX2FwcHN0b3;
    }
    return arc4random()%200;
}
//2
static __attribute__((always_inline)) int PSWebjailFile(){
    for (NSString *key in PSWEBHIDDENFILES) {
        // Check if any of the files exist (should return no)
        if ([[NSFileManager defaultManager] fileExistsAtPath:key]) {
            // Jailbroken
            return arc4random()%10+JA5X2lzX2FwcHN0b3;
        }
    }
    return arc4random()%200;
}

//3
//static __attribute__((always_inline)) int PSWebjailCydiaUrl(){
//    NSURL *FakeURL = [NSURL URLWithString:PSWEBPACKAGEURL];
//    if ([[UIApplication sharedApplication] canOpenURL:FakeURL])
//        return arc4random()%10+JA5X2lzX2FwcHN0b3;
//    else
//        return arc4random()%200;
//
//}

//4
static __attribute__((always_inline)) int PSWebjailfstab() {
    @try {
        struct stat stat_info;
        //（1）返回0，表示指定的文件存在 2）返回－1，表示执行失败，错误代码存于errno中
        if (0==stat("/etc/fstab", &stat_info)){
            return  arc4random()%10+JA5X2lzX2FwcHN0b3;
        }
        else if (0 == stat("/Library/MobileSubstrate/MobileSubstrate.dylib", &stat_info)){
            return  arc4random()%10+JA5X2lzX2FwcHN0b3;
        }
        else if (0 == stat("/Applications/Cydia.app", &stat_info)){
            return  arc4random()%10+JA5X2lzX2FwcHN0b3;
        }
        else if (0 == stat("/var/lib/cydia/", &stat_info)){//返回0，表示指定的文件存在
            return  arc4random()%10+JA5X2lzX2FwcHN0b3;//之前越狱，但后来升级成非越狱的设备，此处仍会检测到存在
        }
        return arc4random()%200;
    }
    @catch (NSException *exception) {
        return 0;
    }
}

//5
static __attribute__((always_inline)) int PSWebjailSymbolicLink(){
    @try {
        NSArray *lnkFiles = @[@"/Library/MobileSubstrate/DynamicLibraries",@"/Applications",@"/usr/share",@"/Library/Wallpaper"];
        struct stat s;
        for (int i=0; i<[lnkFiles count]; i++) {
            int ibk=lstat([[lnkFiles objectAtIndex:i]UTF8String], &s);
            if (ibk== 0) {//（1）返回0，表示指定的文件存在 2）返回－1，表示执行失败，错误代码存于errno中
                if (s.st_mode & S_IFLNK) {//S_IFLNK：文件是一个符号链接
                    return  arc4random()%10+JA5X2lzX2FwcHN0b3;
                }
            }
        }
        return arc4random()%200;
    }
    @catch (NSException *exception) {
        // Not Jailbroken
        return 0;
    }
}

//1-1
static __attribute__((always_inline)) int PSWebjailStatPath(){
    int iFlag=JA5X2lzX2FwcHN0b3-10-arc4random()%200;
    return ^(int aNum){
        @try{
            int ret;
            Dl_info dylib_info;
            int (*func_stat)(const char *,struct stat *) = stat;
            if ((ret = dladdr(func_stat, &dylib_info))) {
                //dylib_info = (dli_fname = "/usr/lib/system/libsystem_kernel.dylib", dli_fbase = 0x00000001806cc000, dli_sname = "stat", dli_saddr = 0x00000001806cf7a0)
                if (strcmp(dylib_info.dli_fname, "/usr/lib/system/libsystem_kernel.dylib")) {
                    //相等(为0)不一定是jail，但不相等，则肯定是被攻击了=非0为=true=表示stat被hook攻击
                    aNum=arc4random()%10+JA5X2lzX2FwcHN0b3;
                }
            }
        }
        @catch(NSException *exception){
        }
        return aNum;
    }(iFlag);
}

//6
static __attribute__((always_inline)) int PSWebjailbreak(){
    int flag=PSWebjailEnv();
    if (flag>=JA5X2lzX2FwcHN0b3) {
        return flag;
    }
    flag=PSWebjailFile();
    if (flag>=JA5X2lzX2FwcHN0b3) {
        return flag;
    }
    flag=PSWebjailfstab();
    if (flag>=JA5X2lzX2FwcHN0b3) {
        return flag;
    }
    flag=PSWebjailSymbolicLink();
    if (flag>=JA5X2lzX2FwcHN0b3) {
        return flag;
    }
    return PSWebjailStatPath();
}

+(NSInteger)PSWebNotBroken{
    return PSWebjailbreak();
}


@end
