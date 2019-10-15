//
//  ppreadSharing.m
//  paopaoread
//
//  Created by 七七 on 2017/12/18.
//  Copyright © 2017年 paopaoread. All rights reserved.
//

#import "ppreadSharing.h"
#import "WXApi.h"
#import "WXApiRequestHandler.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "qrCodeTool.h"


//浏览器包名
//#define QM_SAFARI_PACKAGE   @"com.apple.mobilesafari"

#define logo_Pic @"logo_80.png"
#define KEY_DEFAULT_USER_INFO @"_def_user_info_dict"

@implementation ppreadSharing


-(NSData *)reSizeImageData:(UIImage *)sourceImage maxImageSize:(CGFloat)maxImageSize maxFileSizeWithKB:(CGFloat)maxFileSize
{//压缩图片
    if (maxFileSize <= 0.0)  maxFileSize = 1024.0;
    if (maxImageSize <= 0.0) maxImageSize = 1024.0;

    //先调整分辨率
    CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);

    CGFloat tempHeight = newSize.height / maxImageSize;
    CGFloat tempWidth = newSize.width / maxImageSize;

    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempWidth, sourceImage.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(sourceImage.size.width / tempHeight, sourceImage.size.height / tempHeight);
    }

    UIGraphicsBeginImageContext(newSize);
    [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    CGFloat sizeOriginKB = imageData.length / 1024.0;

    CGFloat resizeRate = 0.9;
    while (sizeOriginKB > maxFileSize && resizeRate > 0.1) {
        imageData = UIImageJPEGRepresentation(newImage,resizeRate);
        sizeOriginKB = imageData.length / 1024.0;
        resizeRate -= 0.1;
    }

    return imageData;
}

+(UIImage *)getThumimageFromImage:(UIImage *)shareImgviewImage{
    CGSize newSize = CGSizeMake(shareImgviewImage.size.width, shareImgviewImage.size.height);
    UIGraphicsBeginImageContext(newSize);
    [shareImgviewImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newThumImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newThumImage;
}

//微信分享  (分享给好友：WXSceneSession) (分享到朋友圈：WXSceneTimeline)
+(void)wechatShare:(int )shareType wechatShareUrl:(NSString *)shareUrl wechatShareDes:(NSString *)shareDes withImgName:(NSString *)imgName{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:_IMAGE(imgName,nil)];

    WXWebpageObject *appObject = [WXWebpageObject object];

    appObject.webpageUrl = shareUrl;
    message.mediaObject = appObject;
    message.description = shareDes;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    req.bText = NO;
    req.scene = shareType;
    [WXApi sendReq:req];
}

+(void)proWechatShareWithInfo:(NSDictionary *)shareInfo failure:(void(^)(NSString * errInfo))failure{
    if(![WXApi isWXAppInstalled])
    {
        if(failure)
            failure(@"无法分享：未检测到微信");
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    UIImage *image=nil;
    NSString *imgUrl=[shareInfo objectForKey:@"shareUrlImage"];//Logo
    if (![clsCommonFunc isEmptyStr:imgUrl]){
        if ([imgUrl hasSuffix:logo_Pic]) {
            image=_IMAGE(logo_Pic, nil);
        }
        else if([imgUrl hasPrefix:@"http"]) {
            image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
        }
    }
    if (!image) {
        image=_IMAGE(logo_Pic, nil);
    }
    [message setThumbImage:image];//分享到朋友圈时，此项无用
    
    int iShareType=[[shareInfo objectForKey:@"shareType"]intValue];
    NSString *strShareImage=[shareInfo objectForKey:@"shareWatermarkImage"];
    UIImage *shareImgviewImage=[shareInfo objectForKey:@"shareImageViewImage"];
    if (shareImgviewImage) {
        //直接分享UIImage图片
        WXImageObject *imageObject=[WXImageObject object];
        imageObject.imageData=UIImagePNGRepresentation(shareImgviewImage);
//        //分享图片到微信好友时预览图即为要分享的图shareImgviewImage，分享到朋友圈不需要显示缩略图，故不需设置
        if (0==iShareType) {
            //缩略图太大会导致分享取消,故需要将缩略图进行压缩至120*120,故暂时仍以logo作为预览图
            //(如果用logo作为预览图，在有的版本微信上接到的图片也是显示的Logo预览图，而不是分享图片，需要点击后才能看到分享图片)
            //需将view转化出的image做以下处理，才能保证每个转出的图片都能微信分享，不然有的色彩丰富的图像转出会失败
            UIImage *newThumImg=[self getThumimageFromImage:shareImgviewImage];
            if (newThumImg) {//大小1095517shareImgviewImage的，转化后的newThumImg大小为355789；
                [message setThumbImage:newThumImg];
            }
        }
        message.mediaObject=imageObject;
    }
    else if (![clsCommonFunc isEmptyStr:strShareImage] && [strShareImage hasPrefix:@"http"]) {
        //分享一张url图片
        UIImage *shareImg=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strShareImage]]];
        WXImageObject *imageObject=[WXImageObject object];
        imageObject.imageData=UIImagePNGRepresentation(shareImg);
        message.mediaObject=imageObject;
    }
    else if([shareInfo objectForKey:@"shareUrlTarget"]){
        WXWebpageObject *appObject = [WXWebpageObject object];
        NSString *shareUrl=[shareInfo objectForKey:@"shareUrlTarget"];
        NSString *shareDes=[shareInfo objectForKey:@"shareUrlSubtitle"];
        NSString *shareTitle=[shareInfo objectForKey:@"shareUrlTitle"];
        appObject.webpageUrl = shareUrl;
        message.mediaObject = appObject;
        message.title=shareTitle;
        message.description = shareDes;
    }
    else{
        if(failure)
            failure(@"分享失败：无效分享信息");
    }
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    req.bText = NO;
    req.scene =iShareType;// [[shareInfo objectForKey:@"shareType"]intValue];
    //    WXSceneSession  = 0,        /**< 聊天界面    */
    //    WXSceneTimeline = 1,        /**< 朋友圈      */
    [WXApi sendReq:req];
    if (failure) {
        failure(@"");
    }
}

+(void)proQQShareWithInfo:(NSDictionary *)shareInfo failure:(void(^)(NSString * errInfo))failure{
    if (![QQApiInterface isQQInstalled]){
        if (failure)
            failure(@"您尚未安装QQ");
        return;
    }
    
    NSString *shareUrl=[shareInfo objectForKey:@"shareUrlTarget"];
    NSString *shareTitle=[shareInfo objectForKey:@"shareUrlTitle"];
    NSString *shareDes=[shareInfo objectForKey:@"shareUrlSubtitle"];
    NSString *imgUrl=[shareInfo objectForKey:@"shareUrlImage"];
    UIImage *shareImage=[shareInfo objectForKey:@"shareImageViewImage"];
    if (![clsCommonFunc isEmptyStr:imgUrl] && [imgUrl hasPrefix:@"http"]) {
        //预览图片为url时
        if (shareImage && shareImage.size.width>0) {
            //分享图片
            NSData *imgData=UIImagePNGRepresentation(shareImage);
            NSData *imgPreviewData=nil;
            UIImage *newThumImg=[self getThumimageFromImage:shareImage];
            if (newThumImg) {
                imgPreviewData=UIImagePNGRepresentation(newThumImg);
            }
            else{
                imgPreviewData=UIImagePNGRepresentation(_IMAGE(logo_Pic,nil));
            }
            QQApiImageObject *imgObj=[QQApiImageObject objectWithData:imgData previewImageData:imgPreviewData title:shareTitle description:shareDes];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
            if (sent!=EQQAPISENDSUCESS) {
                if(failure)
                    failure([NSString stringWithFormat:@"分享失败：errCdoe=%d",sent]);
            }
            else if (failure) {
                failure(@"");
            }
        }
        else if (![clsCommonFunc isEmptyStr:shareUrl]){
            //分享内容及链接
            QQApiNewsObject *newsObject =[QQApiNewsObject objectWithURL:[NSURL URLWithString:shareUrl] title:shareTitle description:shareDes previewImageURL:[NSURL URLWithString:imgUrl]];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObject];
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
            if (sent!=EQQAPISENDSUCESS) {//QQ未打开的情况下，返回的可能是EQQAPIAPPSHAREASYNC
                if(failure)
                    failure([NSString stringWithFormat:@"分享失败：errCdoe=%d",sent]);
            }
            else if (failure) {
                failure(@"");
            }
        }
        else{
            if(failure)
                failure(@"分享失败：无效分享信息");
        }
    }
    else{
        //预览图片为本地时
        if (shareImage && shareImage.size.width>0) {
//            分享图片,此时shareTitle，shareDes无用
            NSData *imgData=UIImagePNGRepresentation(shareImage);
            NSData *imgPreviewData=nil;
            UIImage *newThumImg=[self getThumimageFromImage:shareImage];
            if (newThumImg) {
                imgPreviewData=UIImagePNGRepresentation(newThumImg);//imgData[1095517]>imgPreviewData[355789]
            }
            else{
                imgPreviewData=UIImagePNGRepresentation(_IMAGE(logo_Pic,nil));
            }
            //previewImageData为imgData时有大小32k限制,太大会分享不成功,127361可以,1066886则不行，
            QQApiImageObject *imgObj=[QQApiImageObject objectWithData:imgData previewImageData:imgPreviewData title:shareTitle description:shareDes];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
            if (sent!=EQQAPISENDSUCESS) {
                if(failure)
                    failure([NSString stringWithFormat:@"分享失败：errCdoe=%d",sent]);
            }
            else if (failure) {
                failure(@"");
            }
        }
        else if (![clsCommonFunc isEmptyStr:shareUrl]){
//            分享内容和链接
            NSData *previewImageData=UIImagePNGRepresentation(_IMAGE(logo_Pic,nil));
            QQApiNewsObject *newsObject =[QQApiNewsObject objectWithURL:[NSURL URLWithString:shareUrl] title:shareTitle description:shareDes previewImageData:previewImageData];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObject];
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    //        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];//QQ空间(已不需要了，现在的QQ好友和QQ空间在同一列表中)
            if (sent!=EQQAPISENDSUCESS) {
                if(failure)
                    failure([NSString stringWithFormat:@"分享失败：errCdoe=%d",sent]);
            }
            else if (failure) {
                failure(@"");
            }
        }
        else{
            if(failure)
                failure(@"分享失败：无效分享信息");
        }
    }

}

#pragma mark- 处理invite邀请
+(void)proInviteInType:(NSInteger)iType WithShareInfo:(NSDictionary *)shareInfo failure:(void(^)(NSString * errInfo))failure{
//    iType=1 内容分享微信好友，=2朋友圈图片分享，=3qq分享 =4二维码图片分享至好友 =5朋友圈内容分享
    if (![clsCommonFunc isValidateDict:shareInfo]) {
        if (failure) {
            failure(@"无效的分享信息");
        }
        return;
    }
    
    switch (iType) {
        case 1:
        {//微信好友-内容分享
            NSMutableDictionary *newShareInfo=[NSMutableDictionary dictionaryWithDictionary:shareInfo];
            [newShareInfo setObject:@"0" forKey:@"shareType"];
            [newShareInfo setObject:@"" forKey:@"shareWatermarkImage"];//分享内容的时候清空图片，否则直接分享该图片到微们好友了
            [self proWechatShareWithInfo:[NSDictionary dictionaryWithDictionary:newShareInfo] failure:^(NSString *errInfo) {
                                                    if (failure) {
                                                        failure(errInfo);
                                                    }
                                                }];
        }
            break;
        case 2:
        {//2朋友圈-图片分享
            NSString *shareUrlTarget=[shareInfo objectForKey:@"shareUrlTarget"];
            if ([clsCommonFunc isEmptyStr:shareUrlTarget]) {
                if (failure) {
                    failure(@"无效的分享目标");
                }
                return;
            }
            
            NSString *shareWatermarkImage=[shareInfo objectForKey:@"shareWatermarkImage"];//朋友圈分享照片
            if ([clsCommonFunc isEmptyStr:shareWatermarkImage] || ![shareWatermarkImage hasPrefix:@"http"]) {
                [self proInviteInType:5 WithShareInfo:shareInfo failure:failure];
                return;
            }
            
            UIImage *shareBackImage=nil;
            if ([shareWatermarkImage hasSuffix:@"share_wx.jpg"]) {
                shareBackImage=_IMAGE(@"share_wx.jpg", nil);
            }
            else if ([shareWatermarkImage hasPrefix:@"http"]){//2.0版此处ebug，也写成了hasSuffix
                shareBackImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:shareWatermarkImage]]];
            }
            else{
                shareBackImage=_IMAGE_OF_NAME(shareWatermarkImage);
            }
            if (!shareBackImage || 0==shareBackImage.size.width || 0==shareBackImage.size.height) {//{720, 1352}
                [self proInviteInType:5 WithShareInfo:shareInfo failure:failure];
                return;
            }
            //以此背景为底景，在其上绘制二维码及邀请码等
            //绘制底景
            UIImageView *backImgView=[[UIImageView alloc]initWithImage:shareBackImage];
            [backImgView setFrame:CGRectMake(0, 0, shareBackImage.size.width, shareBackImage.size.height)];
            //绘制用户头像及呢称
            NSDictionary *useDict=_DefaultUserObjectForKey(KEY_DEFAULT_USER_INFO);
            if ([clsCommonFunc isValidateDict:useDict]) {
                NSString *nickName=[useDict objectForKey:@"nickname"];
                NSString *sHeadUrl=[useDict objectForKey:@"headurl"];
                UIImage *headImg=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:sHeadUrl]]];
                UILabel *tmpNickLabel=[clsCommonFunc initALabel:[NSString stringWithFormat:@"—          %@",nickName]  textfont:_SYSFONT(26) textColor:_RGB_HEX_2_COLOR(@"01adb1") textAlign:NSTextAlignmentLeft];
                [backImgView addSubview:tmpNickLabel];
                [tmpNickLabel setFrame:CGRectMake(shareBackImage.size.width/2, 674, shareBackImage.size.width/2-100, 50)];

                if (headImg) {
                    UIImageView *tmpHeadImgView=[[UIImageView alloc]initWithImage:headImg];
                    [backImgView addSubview:tmpHeadImgView];
                    tmpHeadImgView.layer.cornerRadius=50/2;
                    tmpHeadImgView.clipsToBounds=YES;
                    [tmpHeadImgView setFrame:CGRectMake(shareBackImage.size.width/2+30, 674, 50, 50)];
                }
            }
            //绘制二维码
            UIImage *logoImage=_IMAGE(logo_Pic, nil); //[UIImage imageWithData:nil];
            UIImage *qrCodeImage=[qrCodeTool qrCodeImageWithContent:shareUrlTarget codeImageSize:110 logo:logoImage logoFrame:CGRectMake(110/2-30/2, 110/2-30/2, 30, 30) red:0 green:0 blue:0];
            UIImageView *tmpQCodeView=[[UIImageView alloc]initWithImage:qrCodeImage];
            [backImgView addSubview:tmpQCodeView];
            [tmpQCodeView setFrame:CGRectMake(87, shareBackImage.size.height-194-110, 110, 110)];
            //绘制用户邀请码
            NSString *inviteCode=[shareInfo objectForKey:@"inviteCode"];
            if ([clsCommonFunc isEmptyStr:inviteCode]) {
//                inviteCode=[ppUserInfo userIDWithIdfa:NO];
            }
            if (![clsCommonFunc isEmptyStr:inviteCode] && [inviteCode length]>2) {
                UILabel *tmpCodeLabel=[clsCommonFunc initALabel:inviteCode textfont:_SYSFONT(30) textColor:_RGB_HEX_2_COLOR(@"fe7d55") textAlign:NSTextAlignmentCenter];
                [backImgView addSubview:tmpCodeLabel];
                [tmpCodeLabel setFrame:CGRectMake(shareBackImage.size.width/2-10, shareBackImage.size.height-206-30, 160, 40)];
            }
            
            UIGraphicsBeginImageContextWithOptions(shareBackImage.size, NO, 0.0);
            //将backImgView，转成UIImage绘制到Graphics，然后转成UIImage保存或分享到朋友圈
            [backImgView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *theShareImg=UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            //保存UIimage到沙箱
            if (!theShareImg) {
                [self proInviteInType:5 WithShareInfo:shareInfo failure:failure];
                return;
            }
            
            
            NSDictionary *shareDict=[NSDictionary dictionaryWithObjectsAndKeys:theShareImg,@"shareImageViewImage",
                                     @"1",@"shareType",
                                     [shareInfo objectForKey:@"shareUrlImage"],@"shareUrlImage", nil];
            [ppreadSharing proWechatShareWithInfo:shareDict failure:^(NSString *errInfo) {
                if (failure) {
                    failure(errInfo);
                }
        }];

        }
            break;
        case 3:
        {//3qq-内容分享
            [self proQQShareWithInfo:shareInfo failure:^(NSString *errInfo) {
                                                if (failure) {
                                                    failure(errInfo);
                                                }
                                            }];
        }
            break;
        case 4:{
//            4二维码-图片分享到微信
//            [self proInviteInType:5 WithShareInfo:shareInfo failure:failure];
            UIImage *theShotcutShareImage=[shareInfo objectForKey:@"shareImageViewImage"];
            if (!theShotcutShareImage) {
                if (failure) {
                    failure(@"无效的分享图片");
                }
                return;
            }
            [self proWechatShareWithInfo:shareInfo failure:^(NSString *errInfo) {
                                                        if (failure) {
                                                            failure(errInfo);
                                                        }}];
            
        }
            break;
        case 5:{
//            5朋友圈-内容分享
            NSString *sTitle=[shareInfo objectForKey:@"shareUrlSubtitle"];
            if ([clsCommonFunc isEmptyStr:sTitle]) {
                sTitle=[shareInfo objectForKey:@"shareText"];
            }
            NSMutableDictionary *newShareInfo=[NSMutableDictionary dictionaryWithDictionary:shareInfo];
            [newShareInfo setObject:sTitle forKey:@"shareUrlTitle"];//朋友圈内容分享，只有titlet有效
            [newShareInfo setObject:@"1" forKey:@"shareType"];
            [newShareInfo setObject:@"" forKey:@"shareWatermarkImage"];

            [self proWechatShareWithInfo:[NSDictionary dictionaryWithDictionary:newShareInfo] failure:^(NSString *errInfo) {
                                                    if (failure) {
                                                        failure(errInfo);
                                                    }
                                                }];
        }
            break;
        default:
            break;
    }
}
    
    
@end
