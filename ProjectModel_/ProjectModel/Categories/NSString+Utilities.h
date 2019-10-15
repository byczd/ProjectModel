//
//  NSString+Utilities.h
//  HuiBeauty
//
//  Created by darren on 14-9-25.
//  Copyright (c) 2014年 Beijing CHSY E-Business Co.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SECZV9wdwV5X29mX2Fz @"[]:?ilaojin_#$%"
#define V5X29mX2FzZV9wdw @"[]:?Ppnews_#$%"

@interface NSString (Utilities)

-(BOOL)isEmptyString;

- (BOOL)containsString:(NSString*)string;
-(NSUInteger)indexOfSubstring:(NSString *)subStr;
-(NSUInteger)maxIndexOfSubstring:(NSString *)subStr;
- (BOOL)isValidEmail;

- (BOOL)isValidPhoneNo;

- (BOOL)containsOnlyLetters;

- (BOOL)containsOnlyNumbers;

- (NSString*)stringByRemovingPrefix:(NSString*)prefix;

- (NSString *)urlEncode;
    
- (NSString*)urlDecode;

- (NSString*)trim;
-(NSAttributedString *)attrWithFontSize:(int)fontsize
                      selfColor:(UIColor *)selfColor
                      LightText:(NSString *)text
                      LightFont:(int)lfont
                     LightColor:(UIColor *)lightColor;

-(NSAttributedString *)attrWithFont:(UIFont *)font
                      selfColor:(UIColor *)selfColor
                      LightText:(NSString *)text
                      LightFont:(UIFont *)lfont
                     LightColor:(UIColor *)lightColor;

-(NSData *)toJsonData;
-(NSDictionary *)toJsonDict;
-(BOOL)isErrUdid;
-(NSString *)UTF8_URL;
-(NSString *)urlDomain;

-(NSString *)pwEncByASEKey:(NSString *)aKey;
-(NSString *)pwDecByASEKey:(NSString *)aKey;
- (BOOL)isChineseString;
- (BOOL)isChineseCharacter;


+ (NSString *)formatSongTime:(NSTimeInterval)time;
@end
