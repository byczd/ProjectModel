//
//  NSString+Utilities.m
//  HuiBeauty
//
//  Created by darren on 14-9-25.
//  Copyright (c) 2014年 Beijing CHSY E-Business Co.,LTD. All rights reserved.
//

#import "NSString+Utilities.h"
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

#define gIv             @"0102030405060708" //自行修改

@implementation NSString (Utilities)

    
-(BOOL)isEmptyString{
    //if !self 根本不会执行到isEmptyString方法,因为nil不是nsstring类型
    if ([self length] == 0) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)containsString:(NSString*)string {
    return [self rangeOfString:string].location != NSNotFound;
}

-(NSUInteger)indexOfSubstring:(NSString *)subStr{
    return [self rangeOfString:subStr].location;
}

-(NSUInteger)maxIndexOfSubstring:(NSString *)subStr{
    return NSMaxRange([self rangeOfString:subStr]);
}

#define MaxEmailLength 254
- (BOOL)isValidEmail
{//Email格式
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL validEmail = [emailTest evaluateWithObject:self];
    if(validEmail && self.length <= MaxEmailLength)
        return YES;
    return NO;
}

- (BOOL)containsOnlyNumbers
{//全数字
    NSCharacterSet *numbers = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    return ([self rangeOfCharacterFromSet:numbers].location == NSNotFound);
}
    
- (BOOL)containsOnlyLetters
{//全字母
    NSCharacterSet *blockedCharacters = [[NSCharacterSet letterCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
}

- (BOOL)isValidPhoneNo
{//电话号码格式
    static NSString *tempStr = @"^((\\+86)?|\\(\\+86\\))0?1[34578]\\d{9}$";
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]initWithPattern:tempStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
    
    return numberofMatch > 0;
}

- (NSString*)stringByRemovingPrefix:(NSString*)prefix
{//去掉头部str
    NSRange range = [self rangeOfString:prefix];
    if(range.location == 0) {
        return [self stringByReplacingCharactersInRange:range withString:@""];
    }
    return self;
}

- (NSString*)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)urlEncode
{
    //CFURLCreateStringByAddingPercentEscapes 9.0以后弃用
    //    NSString *encodedString = (NSString *)
    //    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
    //                                            (CFStringRef)self,
    //                                            (CFStringRef)@"!$&'()*,-./:;=?@_~%#[]",
    //                                            NULL,
    //                                            kCFStringEncodingUTF8);
    //    return encodedString;
    
    
    //    NSString *encodedValue = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
    //                                                                                                  (CFStringRef)self, nil,
    //                                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    //    NSLog(@"encodedValue=\n%@",encodedValue);
    //    return encodedValue;
    //CFURLCreateStringByAddingPercentEscapes 9.0后弃用，7.0以后都可用以下
    NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
   
    return encodedUrl;
    
}

- (NSString*)urlDecode{
    //    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
    //                                                                                                             (CFStringRef)self,
    //                                                                                                             CFSTR(""),
    //                                                                                                             kCFStringEncodingUTF8));
    //    NSLog(@"result=\n%@",result);
    //    return result;
    
    NSString *result2=[self stringByRemovingPercentEncoding];
    
    return result2;
}




-(NSAttributedString *)attrWithFont:(UIFont *)font
                      selfColor:(UIColor *)selfColor
                      LightText:(NSString *)text
                      LightFont:(UIFont *)lfont
                     LightColor:(UIColor *)lightColor{
    NSString *temp = self;
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:temp];
    [attributeStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0,temp.length)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:selfColor range:NSMakeRange(0,temp.length)];
    
    if (![clsCommonFunc isEmptyStr:text]) {
        NSRange range = [self rangeOfString:text];
        if (range.location!=NSNotFound) {
            [attributeStr addAttribute:NSFontAttributeName value:lfont range:NSMakeRange(range.location,range.length)];
            [attributeStr addAttribute:NSForegroundColorAttributeName value:lightColor range:NSMakeRange(range.location,range.length)];
        }
    }
    return attributeStr;
    
}

-(NSAttributedString *)attrWithFontSize:(int)fontsize
                      selfColor:(UIColor *)selfColor
                      LightText:(NSString *)text
                      LightFont:(int)lfont
                     LightColor:(UIColor *)lightColor
{
    //eg：NSString *temp = [NSString stringWithFormat:@"已逾期%@天",lastDays];
    //then: [temp attrWithFontSize:17 selfColor:_color_white LightText:lastDays LightFont:14 LightColor:_color_Red];
    
    NSString *temp = self;
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:temp];
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontsize] range:NSMakeRange(0,temp.length)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:selfColor range:NSMakeRange(0,temp.length)];
    
    if (![clsCommonFunc isEmptyStr:text]) {
        NSRange range = [self rangeOfString:text];
        if(range.location!=NSNotFound){
            [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:lfont] range:NSMakeRange(range.location,range.length)];
            [attributeStr addAttribute:NSForegroundColorAttributeName value:lightColor range:NSMakeRange(range.location,range.length)];
        }
    }
    return attributeStr;
}

-(NSData *)toJsonData{
    if ([self isEmptyString]) {
        return nil;
    }
    else
        return [self dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSDictionary *)toJsonDict{
    if ([self isEmptyString]) {
        return nil;
    }
    NSData *tmpData=[self toJsonData];
    if (tmpData) {
        return [tmpData tojsonDict];
    }
    else
        return nil;
}

-(BOOL)isErrUdid{
    return ([self length]<10 || [self isEqualToString:@"00000000-0000-0000-0000-000000000000"]);//8-4-4-4-12(36bit),new-udid:00008020-1234C6558268A002E(25bit)
}

-(NSString *)UTF8_URL{
    //NSURL URLWithString:url汉字或者空格等无法被识别,切记会导致返回nil,故需用下面的stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding转换一下
    if (@available(iOS 9.0, *)) {
        return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else{
        return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}

-(NSString *)urlDomain{
    //https://sv.yilan.tv/Starscream/ylm/index.html?id=qJy8ZV6vdjRY&access_key=yl2gcg74rfo8&sudid=10212848&suid=&logid=3639194609&simei=&sidfa=&sadid=&smac=
    NSURL *url=[NSURL URLWithString:self];
    return url.host;
//    url.host=sv.yilan.tv
//    url.path=/Starscream/ylm/index.html
//    url.pathExtension=html
//    url.lastPathComponent=index.html
    
}

-(NSString *)pwEncByASEKey:(NSString *)aKey
{
    if ([self isEmptyString]) {
        return @"";
    }
    NSString *EncryStr=self;
    char keyPtr[kCCKeySizeAES128+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    if ([aKey isEmptyString]) {
        aKey=SECZV9wdwV5X29mX2Fz;
    }
    [aKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [gIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData* data = [EncryStr dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    
    int diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    int newSize = 0;
    
    if(diff > 0)
    {
        newSize = dataLength + diff;
    }
    if (newSize<=0) {
        debugLog(@"------!!!!!!Err-newSize");
        return @"";
    }
    char dataPtr[newSize];
    memcpy(dataPtr, [data bytes], [data length]);
    for(int i = 0; i < diff; i++)
    {
        dataPtr[i + dataLength] = 0x00;
    }
    
    size_t bufferSize = newSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          0x0000,               //No padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          ivPtr,
                                          dataPtr,
                                          sizeof(dataPtr),
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [GTMBase64 stringByEncodingData:resultData];
    }
    free(buffer);
    return nil;
}

-(NSString *)pwDecByASEKey:(NSString *)aKey
{//解密时后面会加上n个\0\0\0\0
    if ([self isEmptyString]) {
        return @"";
    }
    NSString *DecryStr=self;
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    if ([aKey isEmptyString]) {
        aKey=SECZV9wdwV5X29mX2Fz;
    }
    [aKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [gIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData *data = [GTMBase64 decodeData:[DecryStr dataUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          0x0000,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}


//单个字符是否汉字
- (BOOL)isChineseCharacter{
    NSArray *arr=@[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十"];//如果字符为一至十的汉字，下面的方法会认为不是汉字,哭
    if ([arr containsObject:self]) {
        return YES;
    }
    
    int a = [self characterAtIndex:0];//将输入的字符转换成C字符
    if(a > 0x4e00 && a < 0x9fff) {//字符判断再这里
        return YES;
    }
    else
        return NO;
}

//一串字符全为汉字
- (BOOL)isChineseString
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}


//歌曲时间(分:秒)
+ (NSString *)formatSongTime:(NSTimeInterval)time
{
    NSInteger min = time / 60;
    NSInteger second = (NSInteger)time % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", min, second];
}

@end
