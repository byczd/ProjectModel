//
//  ZDMusicPlaying.h
//  paopaoread
//
//  Created by 七七 on 2017/12/15.
//  Copyright © 2017年 paopaoread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pptoolReading : NSObject
+(NSString *)osVersion;
+(NSString *)osBuildVersion;
+ (NSString *)theDevType;
+ (NSString *)theBatteryLeverl;
+ (NSString *_Nullable)getLastDeviceBootTime;
@end
