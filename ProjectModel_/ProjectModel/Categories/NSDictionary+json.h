//
//  NSDictionary+json.h
//  paopaoread
//
//  Created by 七七 on 2018/8/24.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (json)
-(NSData *)tojsonData;
-(NSString *)tojsonPassword;
@end
