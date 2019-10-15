//
//  NSData+json.h
//  paopaoread
//
//  Created by 七七 on 2018/8/24.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (json)
-(NSDictionary *)tojsonDict;
-(NSString *)tojsonString;
@end
