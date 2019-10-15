/*
 @author: ideawu
 @link: https://github.com/ideawu/Objective-C-RSA
*/

#import <Foundation/Foundation.h>

#define xxpubkey @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDA2PfZRlOdQFczSZjMI8ab4YF7KoCdRgfe22Jglaw+dxa/FMcv6aAJj51KpPkA1FrkdFsDQ28pGl9piX/eucp0kVUEQFCVZ9AFosbOPdNqX4twCbP5TWa+VCuXcsUlgfuj7Pdii0DsscjOMDKMZlrR4hj0FU1Ptex+hNSGxEcP3QIDAQAB\n-----END PUBLIC KEY-----"

#define  yyprikey @"-----BEGIN PRIVATE KEY-----\nMIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMDY99lGU51AVzNJmMwjxpvhgXsqgJ1GB97bYmCVrD53Fr8Uxy/poAmPnUqk+QDUWuR0WwNDbykaX2mJf965ynSRVQRAUJVn0AWixs4902pfi3AJs/lNZr5UK5dyxSWB+6Ps92KLQOyxyM4wMoxmWtHiGPQVTU+17H6E1IbERw/dAgMBAAECgYEAlzFD17e4VEAeXZpkzh96VboN3rdq0GMYRpOvZFPUD8EkNzkeFSVQEE7lHaGLiyfx/sxukndrDkmb5k0j0EXPQAofrIuEH5sGsbQ5Gso3uGCuvmfJBrpC/NuP188glt8nnu7cYwm1b7u81NI8LoTwZulKDpMfIrwvoR6LgAoZO80CQQDlgMF0BccqBk7T5b+82RE2UuzmJ/rGT7BnxPw5iGnz8F0jngdWU1Nz74DkDYKOKeMBeD6yjl5WxZV9/+goX/BLAkEA1xzQ623Fe0i3apg4FdBwP1T8dROTzvt57crZoMyUQUxC5yCOvTV/SZgweBHDSIjNoGUesATmuQR5uCQAQsL3dwJBAMvJ4v31S37DjyeVcQZt8Vy9keJlScbiaBAc2KL1wK99lhbUcktzPj1KRLc8T9uQ0iQx8+p1hMukMzRpEmsXlbUCQA+qnJiY3QoWiK0tut/z10j1gpFwRJKNhBrKbEEmxSFgUXsNxveGvud4Owdzm7pbpEYrNynwoXEWH1tG2/IAyw8CQE7eVypEhpcFxXO31eRSh/SQ9fxJvT+8C3xnz8AOPt8shT9zXMMxwJSB2TirqNdAaRaQR31L99zpeGocBzu9sgE=\n-----END PRIVATE KEY-----"

@interface RSA : NSObject

// return base64 encoded string
+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;
// return raw data
+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;
// return base64 encoded string
+ (NSString *)encryptString:(NSString *)str privateKey:(NSString *)privKey;
// return raw data
+ (NSData *)encryptData:(NSData *)data privateKey:(NSString *)privKey;

// decrypt base64 encoded string, convert result to string(not base64 encoded)
+ (NSString *)decryptString:(NSString *)str publicKey:(NSString *)pubKey;
+ (NSData *)decryptData:(NSData *)data publicKey:(NSString *)pubKey;
+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey;
+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)privKey;

@end
