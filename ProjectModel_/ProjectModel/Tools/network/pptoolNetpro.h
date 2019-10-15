//
//  ZDNetInfo.h
//  paopaoread
//
//  Created by 七七 on 2017/12/19.
//  Copyright © 2017年 paopaoread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pptoolNetpro : NSObject
+(BOOL)isNetworkAvailable;
+ (NSString *)currentNetWork;
+ (int) connectedToNetwork;
@end
