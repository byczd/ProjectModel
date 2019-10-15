//
//  CustomBase64.h
//  qm
//
//  Created by qm on 13-9-13.
//  Copyright (c) 2013年 qm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#define key_str_jinbi [@"6YeR5biB" QMBase64Decode]
#define key_str_lingqian [@"6Zu26ZKx" QMBase64Decode]
#define key_str_xiazaishiwan_jinbi [@"5LiL6L296K+V546pIOWNs+WPr+iOt+W+l+mHkeW4geWTpiE=" QMBase64Decode]
#define key_str_xiazai_shiwan [@"5LiL6L296K+V546p" QMBase64Decode]
#define key_str_kanshiping_linjinbi [@"55yL6KeG6aKR5YaN6aKG6YeR5biB" QMBase64Decode]
#define key_str_dengluhou_linjinbi [@"55m75b2V5ZCO5omN6IO96aKG5Y+W6YeR5biB" QMBase64Decode]
#define key_str_fanbei_jinbi [@"6YeR5biB57+75YCN" QMBase64Decode]
#define key_str_gengduo_jinbi [@"5pu05aSa6YeR5biB" QMBase64Decode]
#define key_str_gengduo_fuli [@"5pu05aSa56aP5Yip" QMBase64Decode]
#define key_str_goyuedu_linjinbi [@"5Y676ZiF6K+76aKG6YeR5biB" QMBase64Decode]
#define key_str_yuedurenyipian_linjinbi [@"6ZiF6K+75Lu75oSP5LiA56+H6LWE6K6vIOmDveWPr+S7peiOt+W+l+mHkeW4geWTpg==" QMBase64Decode]

@interface CustomBase64 : NSObject

@end

@interface NSData (Base64)

+ (NSData *)QMdataWithBase64EncodedString:(NSString *)string;
- (NSString *)QMbase64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)QMbase64EncodedString;

@end

@interface NSString (Base64)

+ (NSString *)QMstringWithBase64EncodedString:(NSString *)string encoding:(NSStringEncoding)encoding;
+ (NSString *)QMstringWithBase64EncodedString:(NSString *)string;
- (NSString *)QMbase64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)QMbase64EncodedString:(NSStringEncoding)encoding;
- (NSString *)QMbase64EncodedString;
- (NSString *)QMBase64Decode:(NSStringEncoding)encoding;
- (NSString *)QMBase64Decode;
- (NSData *)QMbase64DecodedData;

- (NSString *)QMauthCodeEncoded:(NSString *)key encoding:(NSStringEncoding)encoding;
- (NSString *)QMauthCodeEncoded:(NSString *)key;
- (NSString *)QMauthCodeDecoded:(NSString *)key encoding:(NSStringEncoding)encoding;
- (NSString *)QMauthCodeDecoded:(NSString *)key;
- (NSString *)QMmd5;
-(BOOL) QMmatchesPatternRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;

-(NSArray *) QMstringsByExtractingUsingRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;
@end

@interface NSString (URL)
- (NSString *)QumiURLEncodedString;
- (NSString *)QumiURLDecodedString;
@end



