//
//  commonLoadPro.h
//  paopaoNews
//
//  Created by jiuXi on 2018/1/24.
//  Copyright © 2018年 jiuXi. All rights reserved.
//

#import <Foundation/Foundation.h>
#define _KEY_LOADED_DATA @"_key_load_dat"

#define _LOADING_STATE_NOTI @"_Loading_State_Noti"

@protocol KDLoadProManagerDelegate<NSObject>
//@required的部份是規定要实现的，@optional的話就隨你高興了,默认设定是@required
@optional
-(void)loadDataIntoCacheNotiWithUrl:(NSString *)url andIndexPath:(NSIndexPath *)theIndexpath;
-(void)loadDataIntoDefaultUserNotiWithUrl:(NSString *)url andData:(NSData *)theData;
-(void)threadLoadNoitInfo:(NSDictionary *)infoDict;
@end

typedef void(^completionHandlerWithData)(NSData *urlData);

@interface KDLoadProManager : NSObject
@property (weak,nonatomic)id<KDLoadProManagerDelegate> delegate;

+(instancetype)sharedInstance;
+(NSString *)getLocalSavePathForUrl:(NSString *)url newDicWhenNoExist:(BOOL)newFlag;
-(void)loadDataIntoDefaultUserFromUrl:(NSString *)url completionHandler:(void(^)(NSData *urlData))handler;
-(void)loadDataIntoCacheFromUrl:(NSString *)url withIndexPath:(NSIndexPath *)theIndexpath completionHandler:(void(^)(NSString *filePath))handler;
-(void)mutiThreadLoadDataFromUrl:(NSString *)url;
-(void)proNotiThreadLoadState:(NSDictionary *)infoDict;
-(void)releaseCacheData;
-(void)mutiThreadLoadDataFromUrl:(NSString *)url intoDefaultUser:(NSString *)userKey completionHandler:(completionHandlerWithData)handler;

-(void)gtData:(NSString *)urlStr withparam:(NSDictionary *)fieldDict completionHandler:(void(^)(NSData *urlData,NSInteger statusCode))completionblk;
-(void)ptData:(NSDictionary *)jsonDic todest:(NSString *)urlStr completionHandler:(void(^)(NSData *urlData))completionblk;
@end




@interface KDLoadPro : NSObject
@property (nonatomic, copy) void (^completionHandler)(NSData *theData);
//@property (nonatomic, assign) BOOL isDataRequestFinish;

- (instancetype)initWithUrl:(NSString *)url;
- (void)startDownload;
-(void)startDownloadWithCompletionHandler:(void(^)(NSData *loadedData))completionHandler;
- (void)cancelDownload;

@end
