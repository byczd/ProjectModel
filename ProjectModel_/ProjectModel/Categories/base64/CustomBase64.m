//
//  CustomBase64.m
//  qm
//
//  Created by qm on 13-9-13.
//  Copyright (c) 2013年 qm. All rights reserved.
//

#import "CustomBase64.h"

@implementation CustomBase64

@end

typedef enum {
    NSStringAuthCodeEncoded,
    NSStringAuthCodeDecoded
} NSStringAuthCode;


@implementation NSData (Base64)

+ (NSData *)QMdataWithBase64EncodedString:(NSString *)string
{
    const char lookup[] =
    {
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99,
        99,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99,
        99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99
    };
    
    NSData *inputData = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    long long inputLength = [inputData length];
    const unsigned char *inputBytes = [inputData bytes];
    
    long long maxOutputLength = (inputLength / 4 + 1) * 3;
    NSMutableData *outputData = [NSMutableData dataWithLength:maxOutputLength];
    unsigned char *outputBytes = (unsigned char *)[outputData mutableBytes];
    
    int accumulator = 0;
    long long outputLength = 0;
    unsigned char accumulated[] = {0, 0, 0, 0};
    for (long long i = 0; i < inputLength; i++)
    {
        unsigned char decoded = lookup[inputBytes[i] & 0x7F];
        if (decoded != 99)
        {
            accumulated[accumulator] = decoded;
            if (accumulator == 3)
            {
                outputBytes[outputLength++] = (accumulated[0] << 2) | (accumulated[1] >> 4);
                outputBytes[outputLength++] = (accumulated[1] << 4) | (accumulated[2] >> 2);
                outputBytes[outputLength++] = (accumulated[2] << 6) | accumulated[3];
            }
            accumulator = (accumulator + 1) % 4;
        }
    }
    
    //handle left-over data
    if (accumulator > 0) outputBytes[outputLength] = (accumulated[0] << 2) | (accumulated[1] >> 4);
    if (accumulator > 1) outputBytes[++outputLength] = (accumulated[1] << 4) | (accumulated[2] >> 2);
    if (accumulator > 2) outputLength++;
    
    //truncate data to match actual output length
    outputData.length = (unsigned long)outputLength;
    return outputLength? outputData: nil;
}

- (NSString *)QMbase64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    //ensure wrapWidth is a multiple of 4
    wrapWidth = (wrapWidth / 4) * 4;
    
    const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    long long inputLength = [self length];
    const unsigned char *inputBytes = [self bytes];
    
    long long maxOutputLength = (inputLength / 3 + 1) * 4;
    maxOutputLength += wrapWidth? (maxOutputLength / wrapWidth) * 2: 0;
    unsigned char *outputBytes = (unsigned char *)malloc((unsigned long)maxOutputLength);
    
    long long i;
    long long outputLength = 0;
    for (i = 0; i < inputLength - 2; i += 3)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i + 2] & 0x3F];
        
        //add line break
        if (wrapWidth && (outputLength + 2) % (wrapWidth + 2) == 0)
        {
            outputBytes[outputLength++] = '\r';
            outputBytes[outputLength++] = '\n';
        }
    }
    
    //handle left-over data
    if (i == inputLength - 2)
    {
        // = terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i + 1] & 0x0F) << 2];
        outputBytes[outputLength++] =   '=';
    }
    else if (i == inputLength - 1)
    {
        // == terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0x03) << 4];
        outputBytes[outputLength++] = '=';
        outputBytes[outputLength++] = '=';
    }
    
    if (outputLength >= 4)
    {
        //truncate data to match actual output length
        outputBytes = realloc(outputBytes, (unsigned long)outputLength);
        return [[NSString alloc] initWithBytesNoCopy:outputBytes
                                              length:(unsigned long)outputLength
                                            encoding:NSASCIIStringEncoding
                                        freeWhenDone:YES];
    }
    else if (outputBytes)
    {
        free(outputBytes);
    }
    return nil;
}

- (NSString *)QMbase64EncodedString
{
    return [self QMbase64EncodedStringWithWrapWidth:0];
}

@end


@implementation NSString (Base64)

+ (NSString *)QMstringWithBase64EncodedString:(NSString *)string encoding:(NSStringEncoding)encoding
{
    NSData *data = [NSData QMdataWithBase64EncodedString:string];
    if (data)
    {
        return [[self alloc] initWithData:data encoding:encoding];
    }
    return nil;
}

+ (NSString *)QMstringWithBase64EncodedString:(NSString *)string
{
    return [self QMstringWithBase64EncodedString:string encoding:NSUTF8StringEncoding];
}

- (NSString *)QMbase64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data QMbase64EncodedStringWithWrapWidth:wrapWidth];
}

- (NSString *)QMbase64EncodedString:(NSStringEncoding)encoding
{
    NSData *data = [self dataUsingEncoding:encoding allowLossyConversion:YES];
    return [data QMbase64EncodedString];
}

- (NSString *)QMbase64EncodedString
{
    return [self QMbase64EncodedString:NSUTF8StringEncoding];
}

- (NSString *)QMBase64Decode:(NSStringEncoding)encoding
{
    return [NSString QMstringWithBase64EncodedString:self encoding:encoding];
}

- (NSString *)QMBase64Decode
{
    return [NSString QMstringWithBase64EncodedString:self];
}

- (NSData *)QMbase64DecodedData
{
    return [NSData QMdataWithBase64EncodedString:self];
}

- (NSString *)QMmd5 {
    const char *concat_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, (CC_LONG)strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

- (NSString *)QMauthCode:(NSString *)auth_key operation:(NSStringAuthCode)operation encoding:(NSStringEncoding)encoding;
{
    
    NSUInteger ckey_length = 0;
    
    NSMutableArray *rndkey = [NSMutableArray array];
    NSMutableArray *box = [NSMutableArray array];
    NSMutableString *result = [NSMutableString string];
    
    NSString *key = [auth_key QMmd5];
    NSString *keya = [[key substringToIndex:16] QMmd5];
    NSString *keyb = [[key substringWithRange:NSMakeRange(16, 16)] QMmd5];
    NSString *keyc = (ckey_length>0) ? ((operation == NSStringAuthCodeDecoded) ? [self substringToIndex:ckey_length] : [[[NSString stringWithFormat:@"%.0f", [[NSDate date]  timeIntervalSince1970]] QMmd5] substringFromIndex:ckey_length]) : @"";
    NSString *cryptkey = [NSString stringWithFormat:@"%@%@",keya,[[NSString stringWithFormat:@"%@%@", keya, keyc] QMmd5]];
    NSUInteger key_length = cryptkey.length;
    
    NSString *string = (operation == NSStringAuthCodeDecoded) ? [[self substringFromIndex:ckey_length] QMBase64Decode:encoding] : [NSString stringWithFormat:@"%@%@%@", @"0000000000", [[[NSString stringWithFormat:@"%@%@",self,keyb] QMmd5] substringToIndex:16], self];
    
    NSUInteger string_length = string.length;
    
    for(int i = 0; i <= 255; i++) {
        [rndkey addObject:[NSNumber numberWithUnsignedShort:[cryptkey characterAtIndex:i%key_length]]];
        [box addObject:[NSNumber numberWithUnsignedShort:i]];
    }
    
    int j = 0;
    for(int i = 0; i < 256; i++) {
        unsigned short b = [[box objectAtIndex:i] unsignedShortValue];
        unsigned short r = [[rndkey objectAtIndex:i] unsignedShortValue];
        j = (j + b + r) % 256;
        [box replaceObjectAtIndex:i withObject:[box objectAtIndex:j]];
        [box replaceObjectAtIndex:j withObject:[NSNumber numberWithUnsignedShort:b]];
    }
    
    int a = 0;
    j = 0;
    for(int i = 0; i < string_length; i++) {
        a = (a + 1) % 256;
        unsigned short b = [[box objectAtIndex:a] unsignedShortValue];
        j = (j + b) % 256;
        [box replaceObjectAtIndex:a withObject:[box objectAtIndex:j]];
        [box replaceObjectAtIndex:j withObject:[NSNumber numberWithUnsignedShort:b]];
        
        unsigned short sc = [string characterAtIndex:i];
        unsigned short bi = [[box objectAtIndex:(([[box objectAtIndex:a] unsignedShortValue] + [[box objectAtIndex:j] unsignedShortValue]) % 256)] unsignedShortValue];
        unsigned short k = sc ^ bi;
        [result appendFormat:@"%C",k];
    }
    
    if(operation == NSStringAuthCodeDecoded) {
        NSString *start = [result substringWithRange:NSMakeRange(10, 16)];
        NSString *end = [[[NSString stringWithFormat:@"%@%@",[result substringFromIndex:26],keyb] QMmd5]  substringToIndex:16];
        if([start isEqualToString:end]){
            return [result substringFromIndex:26];
        }
        else{
            return nil;
        }
    } else {
        return [NSString stringWithFormat:@"%@%@", keyc, [[result QMbase64EncodedString:encoding] stringByReplacingOccurrencesOfString:@"=" withString:@""]];
    }
}

- (NSString *)QMauthCodeEncoded:(NSString *)key encoding:(NSStringEncoding)encoding
{
    return [self QMauthCode:key operation:NSStringAuthCodeEncoded encoding:encoding];
}

- (NSString *)QMauthCodeEncoded:(NSString *)key
{
    return [self QMauthCodeEncoded:key encoding:NSUTF8StringEncoding];
}

- (NSString *)QMauthCodeDecoded:(NSString *)key encoding:(NSStringEncoding)encoding
{
    return [self QMauthCode:key operation:NSStringAuthCodeDecoded encoding:encoding];
}

- (NSString *)QMauthCodeDecoded:(NSString *)key
{
    return [self QMauthCodeDecoded:key encoding:NSUTF8StringEncoding];
}

-(BOOL) QMmatchesPatternRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine {
    NSUInteger options=0;
    if (ignoreCase) {
        options = options | NSRegularExpressionCaseInsensitive;
    }
    if (assumeMultiLine) {
        options = options | NSRegularExpressionDotMatchesLineSeparators;
    }
    
    NSError *error=nil;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:&error];
    if (error) {
        debugLog(@"Error creating Regex: %@",[error description]);
        return NO;  //Can't possibly match an invalid Regex
    }
    
    return ([pattern numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])] > 0);
}


-(NSArray *) QMstringsByExtractingUsingRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine {
    NSUInteger options=0;
    if (ignoreCase) {
        options = options | NSRegularExpressionCaseInsensitive;
    }
    if (assumeMultiLine) {
        options = options | NSRegularExpressionDotMatchesLineSeparators;
    }
    
    NSError *error=nil;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:&error];
    if (error) {
        debugLog(@"Error creating Regex: %@",[error description]);
        return nil;
    }
    
    return [pattern matchesInString:self options:options range:NSMakeRange(0, [self length])];
}

@end

@implementation NSString (URL)

- (NSString *)QumiURLEncodedString
{
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
    NSLog(@"encodedUrl=\n%@",encodedUrl);
    return encodedUrl;
}

- (NSString*)QumiURLDecodedString{
//    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
//                                                                                                             (CFStringRef)self,
//                                                                                                             CFSTR(""),
//                                                                                                             kCFStringEncodingUTF8));
//    NSLog(@"result=\n%@",result);
//    return result;
    
    NSString *result2=[self stringByRemovingPercentEncoding];
    NSLog(@"result2=\n%@",result2);
    return result2;
}
@end
