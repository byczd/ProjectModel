//
//  qrCodeTool.h
//  paopaoread
//
//  Created by 七七 on 2018/11/22.
//  Copyright © 2018年 paopao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface qrCodeTool : NSObject
//生成最原始的二维码
+ (CIImage *)qrCodeImageWithContent:(NSString *)content;
//生成指定尺寸的二维码
+ (UIImage *)qrCodeImageWithContent:(NSString *)content codeImageSize:(CGFloat)size;
//生成指定颜色的二维码（rgb：0-1）
+ (UIImage *)qrCodeImageWithContent:(NSString *)content codeImageSize:(CGFloat)size red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
//生成指定颜色及大小及带Logo的二维码
+ (UIImage *)qrCodeImageWithContent:(NSString *)content
                      codeImageSize:(CGFloat)size
                               logo:(UIImage *)logo
                          logoFrame:(CGRect)logoFrame
                                red:(CGFloat)red
                              green:(CGFloat)green
                               blue:(CGFloat)blue;
//CIImage转成指定大小的UIImage
+(UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;
+(void)saveImageToPhoteAlbum:(UIImage *)image completionHandler:(nullable void(^)(BOOL success, NSString *error))completionHandler;
+(UIImage *)conertViewToImage:(UIView *)aView;
@end
