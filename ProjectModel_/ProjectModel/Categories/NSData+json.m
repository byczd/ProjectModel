//
//  NSData+json.m
//  paopaoread
//
//  Created by 七七 on 2018/8/24.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#import "NSData+json.h"

@implementation NSData (json)
-(NSDictionary *)tojsonDict{
    return [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableLeaves error:nil];
}
-(NSString *)tojsonString{
   return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}
@end
