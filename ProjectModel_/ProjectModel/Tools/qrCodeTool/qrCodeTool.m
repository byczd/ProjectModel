//
//  qrCodeTool.m
//  paopaoread
//
//  Created by 七七 on 2018/11/22.
//  Copyright © 2018年 paopao. All rights reserved.
//

#import "qrCodeTool.h"
#import <Photos/Photos.h>

@implementation qrCodeTool

//生成最原始的二维码
+ (CIImage *)qrCodeImageWithContent:(NSString *)content{
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [qrFilter setValue:contentData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
//    二维码精度,
//    L　: 7% 此时二维码的密度最稀，如果二维码中的内容非常丰富时，建议用L设置，如果还想在二维码中添加logo，logo所在面积不超过二维码图片面积的7%，如果超过这个比例，就会导致图片无法识别
//    M　: 15%
//    Q　: 25%
//    H　: 30% 此时二维码的密度最密，如果二维码中的内容比较简单，建议用H设置，如果还想在二维码中添加logo，logo所在面积不超过二维码图片面积的30%，如果超过这个比例，就会导致图片无法识别
    CIImage *image = qrFilter.outputImage;
    return image;
}

//生成指定尺寸的二维码
+ (UIImage *)qrCodeImageWithContent:(NSString *)content codeImageSize:(CGFloat)size{
    CIImage *image = [self qrCodeImageWithContent:content];
    CGRect integralRect = CGRectIntegral(image.extent);
    if (60==size) {
        size=61;//好奇怪，=60时在微信中长按无法识别，只能扫码识别，>=61长按可以识别，,<60长按也能识别
    }
    CGFloat scale = MIN(size/CGRectGetWidth(integralRect), size/CGRectGetHeight(integralRect));
    size_t width = CGRectGetWidth(integralRect)*scale;
    size_t height = CGRectGetHeight(integralRect)*scale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:integralRect];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, integralRect, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(colorSpaceRef);
    UIImage *result=[UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return result;
}

//生成指定颜色及大小的二维码
+ (UIImage *)qrCodeImageWithContent:(NSString *)content codeImageSize:(CGFloat)size red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue{
    UIImage *image = [self qrCodeImageWithContent:content codeImageSize:size];
    int imageWidth = image.size.width;
    int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpaceRef, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    //遍历像素, 改变像素点颜色
    int pixelNum = imageWidth * imageHeight;
    uint32_t *pCurPtr = rgbImageBuf;
    for (int i = 0; i<pixelNum; i++, pCurPtr++) {
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red*255;
            ptr[2] = green*255;
            ptr[1] = blue*255;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    //取出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpaceRef,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpaceRef);
    
    return resultImage;
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

//生成指定颜色及大小及有Logo的二维码
+ (UIImage *)qrCodeImageWithContent:(NSString *)content
                      codeImageSize:(CGFloat)size
                               logo:(UIImage *)logo
                          logoFrame:(CGRect)logoFrame
                                red:(CGFloat)red
                              green:(CGFloat)green
                               blue:(CGFloat)blue{
    
    UIImage *image = [self qrCodeImageWithContent:content codeImageSize:size red:red green:green blue:blue];
    //有 logo 则绘制 logo
    if (logo != nil) {
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        [logo drawInRect:logoFrame];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImage;
    }else{
        return image;
    }
    
}

//CIIMage->uiImage
+(UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
     // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGColorSpaceRelease(cs);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *result=[UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return result;
}


+(void)saveImageToPhoteAlbum:(UIImage *)image completionHandler:(nullable void(^)(BOOL success, NSString *error))completionHandler{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        //若未拒绝，则会触发系统提示(并且会挂起，待用户做出选择后，才会触发block)//若已拒绝，则status直接返回拒绝，无系统提示
        if (status == PHAuthorizationStatusRestricted || status==PHAuthorizationStatusDenied){
           //refused
            if (completionHandler) {
                //如果初始化授权时，此时会弹出授权对话框，并同时会返回失败，故需先判断是否已授权
                completionHandler(NO,@"NeedAuthorized");
            }
//            [uMengCNZZ uMengEventWithDefaultDictAndEventID:EVENT_REPORT andType:@"AUTHOR[PHOTO-DENIED]" andDetail:nil];
        }
        else //
        {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //        /写入图片到相册
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];//PHAssetChangeRequest *req =
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completionHandler) {
                    //如果初始化授权时，此时会弹出授权对话框，但不会挂起，而直接直接触发block并会返回失败，故需先判断是否已授权
                    completionHandler(success,[error localizedDescription]);
                }
            }];
            
            if (status == PHAuthorizationStatusAuthorized){
//                [uMengCNZZ uMengEventWithDefaultDictAndEventID:EVENT_REPORT andType:@"AUTHOR[PHOTO-ALLOWED]" andDetail:nil];
            }
        }
        
    }];
    
   
}


+(UIImage *)conertViewToImage:(UIView *)aView{
    if (!aView) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size, NO, 0.0);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *theShareImg=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theShareImg;
}

@end
