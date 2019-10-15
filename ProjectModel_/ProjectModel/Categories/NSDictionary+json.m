//
//  NSDictionary+json.m
//  paopaoread
//
//  Created by 七七 on 2018/8/24.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#import "NSDictionary+json.h"

@implementation NSDictionary (json)
-(NSData *)tojsonData{
    return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
}
-(NSString *)tojsonPassword{
    //NSDictionary->json[string]
    NSData *tmpData=[self tojsonData];
    if (tmpData) {
         return [tmpData tojsonString];
    }
    else
        return @"";
}
@end
