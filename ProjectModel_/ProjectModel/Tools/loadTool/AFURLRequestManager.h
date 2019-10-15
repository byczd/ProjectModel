//
//  commonLoadPro.h
//  doudouComeOn
//
//  Created by 七七 on 2018/1/24.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#import <Foundation/Foundation.h>


#define _KEY_LOADED_DATA @"_key_load_dat"

#define _LOADING_STATE_NOTI @"_Loading_State_Noti"

@protocol AFURLRequestManagerDelegate<NSObject>
//@required的部份是規定要实现的，@optional的話就隨你高興了,默认设定是@required
@optional
-(void)loadDataIntoCacheNotiWithUrl:(NSString *)url andIndexPath:(NSIndexPath *)theIndexpath;
-(void)loadDataIntoDefaultUserNotiWithUrl:(NSString *)url andData:(NSData *)theData;
-(void)threadLoadNoitInfo:(NSDictionary *)infoDict;
@end

typedef void(^completionHandlerWithData)(NSData *urlData);

@interface AFURLRequestManager : NSObject
@property (weak,nonatomic)id<AFURLRequestManagerDelegate> delegate;

+(instancetype)sharedInstance;
+(NSString *)getLocalSavePathForUrl:(NSString *)url newDicWhenNoExist:(BOOL)newFlag;
-(void)loadDataIntoDefaultUserFromUrl:(NSString *)url completionHandler:(void(^)(NSData *urlData))handler;
-(void)loadDataIntoCacheFromUrl:(NSString *)url withIndexPath:(NSIndexPath *)theIndexpath completionHandler:(void(^)(NSString *filePath))handler;
-(void)mutiThreadLoadDataFromUrl:(NSString *)url;
-(void)proNotiThreadLoadState:(NSDictionary *)infoDict;
-(void)releaseCacheData;
-(void)mutiThreadLoadDataFromUrl:(NSString *)url intoDefaultUser:(NSString *)userKey completionHandler:(completionHandlerWithData)handler;

-(void)getJsonData:(NSString *)urlStr withparam:(NSDictionary *)fieldDict completionHandler:(void(^)(NSData *urlData,NSInteger statusCode))completionblk;
-(void)postFormData:(NSDictionary *)formDict withJsonDataType:(BOOL)isJsonData todest:(NSString *)urlStr completionHandler:(void(^)(NSData *urlData))completionblk;
-(void)postJsonData:(NSDictionary *)jsonDict forKey:(NSString *)theKey todest:(NSString *)urlStr completionHandler:(void(^)(NSData *urlData))completionblk;
-(void)postJsonData:(NSDictionary *)jsonDict forKey:(NSString *)theKey todest:(NSString *)urlStr withheadInfo:(NSDictionary *)headInfo completionHandler:(void(^)(NSData *urlData))completionblk;
//获取指定APP在appstore指定关键词中的排名，蝉大师接口
-(void)test_to_PostFormData;
@end




@interface AFURLRequestLoader : NSObject
@property (nonatomic, copy) void (^completionHandler)(NSData *theData);
//@property (nonatomic, assign) BOOL isDataRequestFinish;

- (instancetype)initWithUrl:(NSString *)url;
- (void)startDownload;
-(void)startDownloadWithCompletionHandler:(void(^)(NSData *loadedData))completionHandler;
- (void)cancelDownload;

@end
