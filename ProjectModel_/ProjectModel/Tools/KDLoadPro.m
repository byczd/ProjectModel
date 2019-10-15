//
//  musicInfoLoadPro.m
//  paopaoNews
//
//  Created by jiuXi on 2018/1/24.
//  Copyright © 2018年 jiuXi. All rights reserved.
//

#import "KDLoadPro.h"
//#import "NSString+Utilities.h"
//#import "musicManager.h"

//#import "Encryption.h"

@interface KDLoadProManager(){
    dispatch_semaphore_t _lock;
}
@property (nonatomic, strong) NSMutableDictionary *theLoadingInfoDict;
@end

@implementation KDLoadProManager

static id _sharedInstance = nil;
static dispatch_semaphore_t _globalInstancesLock;

+(instancetype)sharedInstance
{
    static dispatch_once_t p;
    dispatch_once(&p, ^{
        _sharedInstance = [[self alloc] init];
        _globalInstancesLock = dispatch_semaphore_create(1);
    });
    return _sharedInstance;
}

-(void)init_lock{
    if(!_lock)
        _lock=_globalInstancesLock;
}

-(void)loadDataIntoDefaultUserFromUrl:(NSString *)url completionHandler:(void(^)(NSData *urlData))handler{
    //保存url数据到[NSUserDefaults standardUserDefaults]中，setObject([nsData,url_md5]) forkey:_KEY_LOADED_DATA
    //md5key为url的md5值//下载完成后，可以直接读取key所存的nsdata,可以在completeEvent中直接读取
    if ([clsCommonFunc isEmptyStr:url]) {
        return;
    }
    
    [self init_lock];
    Lock_self_lock();
    NSString *md5Key=[url QMmd5];
    KDLoadPro *downloader=nil;
    if (_theLoadingInfoDict) {
        downloader = (self.theLoadingInfoDict)[md5Key];
    }
    else{
        _theLoadingInfoDict=[NSMutableDictionary dictionaryWithCapacity:0];
    }
    Unlock_self_lock();
    
    
    if (downloader == nil)
    {
        downloader = [[KDLoadPro alloc] initWithUrl:url];
        [downloader setCompletionHandler:^(NSData *theData){
            LOCK_lock_Auto([self.theLoadingInfoDict removeObjectForKey:md5Key]);
            if (theData){
                Lock_self_lock();
                NSMutableDictionary *existDic=[NSMutableDictionary dictionaryWithDictionary: _DefaultUserObjectForKey(_KEY_LOADED_DATA)];
                if (existDic) {
                    [existDic setObject:theData forKey:md5Key];
                    NSDictionary *saveDic=[NSDictionary dictionaryWithDictionary:existDic];
                    _DefaultUserSaveOjbectForKey(saveDic, _KEY_LOADED_DATA);
                }
                else{
                    NSDictionary *saveDic=[NSDictionary dictionaryWithObjectsAndKeys:theData,md5Key,nil];
                    _DefaultUserSaveOjbectForKey(saveDic, _KEY_LOADED_DATA);
                }
                _DefaultUserSure;
                Unlock_self_lock();
                
                if (handler) {
                    handler(theData);
                }
                if(_delegate && [_delegate respondsToSelector:@selector(loadDataIntoDefaultUserNotiWithUrl:andData:)]) {
                    //不便于使用handler的地方，使用_delegate来通知
                    [_delegate loadDataIntoDefaultUserNotiWithUrl:url andData:theData];
                }
            }
            else{
                ppLog(@"---!!!startLoad-Fail[%@]",url);
                if(_delegate && [_delegate respondsToSelector:@selector(loadDataIntoDefaultUserNotiWithUrl:andData:)]) {
                    //不便于使用handler的地方，使用_delegate来通知
                    [_delegate loadDataIntoDefaultUserNotiWithUrl:url andData:nil];
                }
                if (handler) {
                    handler(nil);
                }
            }
        }];
        LOCK_lock_Auto((self.theLoadingInfoDict)[md5Key] = downloader);
        [downloader startDownload];
    }
}

-(void)loadDataIntoCacheFromUrl:(NSString *)url withIndexPath:(NSIndexPath *)theIndexpath completionHandler:(void(^)(NSString *filePath))handler{
    //theIndexpath对应于tablecell相关数据的更usr，如果不是更新cell信息时，为nil即可
    if ([clsCommonFunc isEmptyStr:url]) {
        return;
    }
    
    [self init_lock];
    Lock_self_lock();
    NSString *md5Key=[url QMmd5];
    KDLoadPro *downloader=nil;
    if (_theLoadingInfoDict) {
        downloader = (self.theLoadingInfoDict)[md5Key];
    }
    else{
        _theLoadingInfoDict=[NSMutableDictionary dictionaryWithCapacity:0];
    }
    Unlock_self_lock();
    
    if (downloader == nil)
    {
        downloader = [[KDLoadPro alloc] initWithUrl:url];
        [downloader setCompletionHandler:^(NSData *theData){
            LOCK_lock_Auto([self.theLoadingInfoDict removeObjectForKey:md5Key]);
            NSString *filePath=[KDLoadProManager getLocalSavePathForUrl:url newDicWhenNoExist:YES];
            if (theData && [theData writeToFile:filePath atomically:YES]){
                if (handler) {
                    handler(filePath);
                }
            }
            else{
                ppLog(@"-----!!!startLoad[%@]>Fail-filePath=%@",url,filePath);
                if (handler) {
                    handler(nil);
                }
            }
            if(_delegate && [_delegate respondsToSelector:@selector(loadDataIntoCacheNotiWithUrl:andIndexPath:)]) {
                [_delegate loadDataIntoCacheNotiWithUrl:url andIndexPath:theIndexpath];
            }
        }];
        LOCK_lock_Auto((self.theLoadingInfoDict)[md5Key] = downloader);
        [downloader startDownload];
    }
}


+(NSString *)getLocalSavePathForUrl:(NSString *)url newDicWhenNoExist:(BOOL)newFlag{
    if ([clsCommonFunc isEmptyStr:url]) {
        return nil;
    }
    NSString *extension =[url pathExtension];//没有后缀的链接使用loadDataIntoDefaultUserFromUrl来load
    NSString *musicFileName=[NSString stringWithFormat:@"%@.%@",[url QMmd5],extension];
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (newFlag) {
        BOOL isDir =NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *m4adir=[NSString stringWithFormat:@"%@/datcache/", docDirPath];
        BOOL existed = [fileManager fileExistsAtPath:m4adir isDirectory:&isDir];
        if ( !(isDir ==YES && existed == YES) ){//如果没有文件夹则创建
            @try{
                [fileManager createDirectoryAtPath:m4adir withIntermediateDirectories:YES attributes:nil error:nil];
            }
            @catch(NSException *err){return nil;}
        }
        NSString *filePath = [NSString stringWithFormat:@"%@%@", m4adir , musicFileName];
        return filePath;
    }
    else{
        return  [NSString stringWithFormat:@"%@/datcache/%@", docDirPath,musicFileName];
    }
}


-(void)proNotiThreadLoadState:(NSDictionary *)infoDict{
    if (_delegate) {
        if([_delegate respondsToSelector:@selector(threadLoadNoitInfo:)]) {
            [_delegate threadLoadNoitInfo:infoDict];
        }
    }
}

- (void)beginThreadLoadFromUrl:(NSString *)url{
    //模拟下载延迟
    [NSThread sleepForTimeInterval:1.5f];
    //将资源转换为二进制
    NSString *urlStr =[url UTF8_URL];// [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *theURL = [[NSURL alloc]initWithString:urlStr];
    NSData *data=[NSData dataWithContentsOfURL:theURL];
    [self performSelectorOnMainThread:@selector(freshUIWithData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:data,@"data",url,@"url", nil] waitUntilDone:YES];
    //    这个函数表示在主线程上执行方法，YES表示需要阻塞主线程，知道主线程将我们的代码块执行完毕。
}

-(void)mutiThreadLoadDataFromUrl:(NSString *)url{
    if ([clsCommonFunc isEmptyStr:url]) {
        return;
    }
    NSDictionary *tmpDict=[NSDictionary dictionaryWithObjectsAndKeys:url,@"url",@"Load",@"state", nil];
    [self proNotiThreadLoadState:tmpDict];//通知界面显示loading提示
    [[NSNotificationCenter defaultCenter] postNotificationName:_LOADING_STATE_NOTI object:nil userInfo:tmpDict];
    NSThread *thread=[[NSThread alloc]initWithTarget:self selector:@selector(beginThreadLoadFromUrl:) object:url];
    [thread start];
}


- (void)beginThreadLoadFromDict:(NSDictionary *)theDict{
    if (!theDict) {
        return;
    }
    NSString *surl=[theDict objectForKey:@"url"];
    NSString *sUserKey=[theDict objectForKey:@"userKey"];
    completionHandlerWithData cplHandler=[theDict objectForKey:@"completionHandler"];
    //模拟下载延迟
    //    [NSThread sleepForTimeInterval:0.5f];
    //    [self loadDataIntoDefaultUserFromUrl:surl withDefaultUserKey:sUserKey completionHandler:handler];
    //不能直接用上面这个，里面有对同一个NSMutableDictionary对象_theLoadingInfoDict的操作，多线程操作这样同一个对象，会出问题；
    
    KDLoadPro *downloader = [[KDLoadPro alloc] initWithUrl:surl];
    NSString *md5Key=[surl QMmd5];
    [downloader startDownloadWithCompletionHandler:^(NSData *loadedData) {
        if (loadedData){
            NSString *sDefUserkey=sUserKey;
            if ([clsCommonFunc isEmptyStr:sDefUserkey]) {
                sDefUserkey=_KEY_LOADED_DATA;
            }
            NSMutableDictionary *existDic=[NSMutableDictionary dictionaryWithDictionary: _DefaultUserObjectForKey(sDefUserkey)];
            if (existDic) {
                [existDic setObject:loadedData forKey:md5Key];
                NSDictionary *saveDic=[NSDictionary dictionaryWithDictionary:existDic];
                _DefaultUserSaveOjbectForKey(saveDic, sDefUserkey);
            }
            else{
                NSDictionary *saveDic=[NSDictionary dictionaryWithObjectsAndKeys:loadedData,md5Key,nil];
                _DefaultUserSaveOjbectForKey(saveDic, sDefUserkey);
            }
            _DefaultUserSure;
            if (cplHandler) {
                cplHandler(loadedData);
            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(loadDataIntoDefaultUserNotiWithUrl:andData:)]) {
                //不便于使用handler的地方，使用_delegate来通知
                [self.delegate loadDataIntoDefaultUserNotiWithUrl:surl andData:loadedData];
            }
            ppLog(@"loadOverFor>%@",surl);
        }
        else{
            ppLog(@"---!!!startLoad-Fail[%@]",surl);
            if (cplHandler) {
                cplHandler(nil);
            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(loadDataIntoDefaultUserNotiWithUrl:andData:)]) {
                //不便于使用handler的地方，使用_delegate来通知
                [self.delegate loadDataIntoDefaultUserNotiWithUrl:surl andData:nil];
            }
        }
    }];
    
    //或者直接dataWithContentsOfURL下载
    //    NSString *urlStr = [surl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    NSURL *theURL = [[NSURL alloc]initWithString:urlStr];
    //    NSData *theData=[NSData dataWithContentsOfURL:theURL];//也可以直接用此方法，只不过不能断点下载
}

-(void)mutiThreadLoadDataFromUrl:(NSString *)url intoDefaultUser:(NSString *)userKey completionHandler:(completionHandlerWithData)handler{
    //多线程下载，并将数据存于userkey沙箱(如果userkey不为空的话)
    if ([clsCommonFunc isEmptyStr:url]) {
        return;
    }
    NSDictionary *tmpDict=[NSDictionary dictionaryWithObjectsAndKeys:url,@"url",userKey,@"userKey",handler,@"completionHandler" ,nil];
    //将block存在dict中，解析后即可直接用block回传相关操作
    NSThread *thread=[[NSThread alloc]initWithTarget:self selector:@selector(beginThreadLoadFromDict:) object:tmpDict];
    [thread start];
}


- (void)freshUIWithData:(NSDictionary *)dataDict{
    if (!dataDict) {
        [self proNotiThreadLoadState:[NSDictionary dictionaryWithObjectsAndKeys:@"Error", @"state",nil]];//通知Fail
         return;
    }
    NSString *url=[dataDict objectForKey:@"url"];
    NSData *urlData=[dataDict objectForKey:@"data"];
    if (!urlData) {
        NSDictionary *tmpDict=[NSDictionary dictionaryWithObjectsAndKeys:url,@"url",@"Fail",@"state", nil];
        [self proNotiThreadLoadState:tmpDict];
        [[NSNotificationCenter defaultCenter] postNotificationName:_LOADING_STATE_NOTI object:nil userInfo:tmpDict];
    }
    
    NSString *filePath =[KDLoadProManager getLocalSavePathForUrl:url newDicWhenNoExist:YES];
   if(filePath && [urlData writeToFile:filePath atomically:YES])//保存所有存储路径以便清理
   {
       //通知成功
       NSDictionary *tmpDict=[NSDictionary dictionaryWithObjectsAndKeys:url,@"url",filePath,@"state", nil];
       [self proNotiThreadLoadState:tmpDict];
       [[NSNotificationCenter defaultCenter] postNotificationName:_LOADING_STATE_NOTI object:nil userInfo:tmpDict];
//       [[musicManager sharedInstance]playALoadedMusic:filePath];//此分页版本做特殊处理，兼容列表循环播放功能；
   }
   else{
       //通知Err
       NSDictionary *tmpDict=[NSDictionary dictionaryWithObjectsAndKeys:url,@"url",@"Error",@"state", nil];
       [self proNotiThreadLoadState:tmpDict];
       [[NSNotificationCenter defaultCenter] postNotificationName:_LOADING_STATE_NOTI object:nil userInfo:tmpDict];
   }
}


-(void)releaseCacheData{
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *m4adir=[NSString stringWithFormat:@"%@/datcache/", docDirPath];
    @try{
        [fileManager removeItemAtPath:m4adir error:nil];
    }
    @catch(NSException *err){
        NSLog(@"Err=%@",err);
    }
    _DefaultUserRemoveOjbectForKey(_KEY_LOADED_DATA);
    [self performSelector:@selector(proNotiThreadLoadState:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Clear",@"state", nil]  afterDelay:2.0f];
}

-(NSString *)ecode_by_AES128Encrypt:(NSString *)origStr{
    return [[Encryption AES128Encrypt:origStr key:V5X29mX2FzZV9wdw] QumiURLEncodedString];
}

-(void)gtData:(NSString *)urlStr withparam:(NSDictionary *)fieldDict completionHandler:(void(^)(NSData *urlData,NSInteger statusCode))completionblk{
#ifndef JJ_ANTI_DUG
    UMSOCIAL_MGR;
#endif
//    NSString *encodeStr = [[Encryption AES128Encrypt:arg2 key:V5X29mX2FzZV9wdw] QumiURLEncodedString];
//    NSString *urlString = [NSString stringWithFormat:@"%@?r=%@&m=%@",arg1,encodeStr,arg3];
    //传输加密信息，放到调用层处理
    ppLog(@"========gtData_from[%@]",urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:NET_DELAY_TIME];
    if (fieldDict) {
        //是否有附加信息
        //    [request addValue:@"2" forHTTPHeaderField:@"PLATFORM"];
        for (NSString *perFieldName in fieldDict) {
            [request addValue:[fieldDict objectForKey:perFieldName] forHTTPHeaderField:perFieldName];
        }
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
            if (data && [data length] > 0 && error == nil) {
                if (completionblk){
                    completionblk(data,urlResponse.statusCode);
                }
//                NSString *strjson = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            }else{
                if(completionblk)
                    completionblk(nil,urlResponse.statusCode);
            }
        });
    }];
    
    [task resume];
    
}

-(void)ptData:(NSDictionary *)jsonDic todest:(NSString *)urlStr completionHandler:(void(^)(NSData *urlData))completionblk{
    
//    NSString *encodeStr = [[Encryption AES128Encrypt:arg1 key:V5X29mX2FzZV9wdw] QumiURLEncodedString];
//    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] initWithCapacity:0];
//    [jsonDic setValue:encodeStr forKey:@"data"];
    ppLog(@"========gtData_from[%@]",urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod =@"POST";
    if (jsonDic) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
        request.HTTPBody = jsonData;
    }

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;//NSURLRequestReloadIgnoringLocalCacheData
    config.networkServiceType = NSURLNetworkServiceTypeDefault;
    config.timeoutIntervalForRequest = NET_DELAY_TIME;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task2 = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if (urlResponse && urlResponse.statusCode==200) {
            if(completionblk)
                completionblk(data);
        }
        else if (completionblk)
            completionblk(nil);
    }];

    [task2 resume];
}


@end


@interface KDLoadPro()
// the queue to run our "ParseOperation"
//@property (nonatomic, strong) NSOperationQueue *queue;

// url session task
@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;
@property (nonatomic, strong) NSString *sUrl;
@end

@implementation KDLoadPro

- (instancetype)initWithUrl:(NSString *)url{
    if (self=[super init]) {
        self.sUrl=url;
    }
    return self;
}

- (void)startDownload
{
    //URLWithString貌似汉字或者空格等无法被识别,切记会导致返回nil,故需用下面的stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding转换一下
    NSString *urlStr =[self.sUrl UTF8_URL];// [self.sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    // create an session data task to obtain and download the app icon
    _sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                       [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                                           // call our completion handler to tell our client that our icon is ready for display
                                                           if (self.completionHandler != nil)
                                                           {
                                                               self.completionHandler(error==nil?data:nil);
                                                           }
                                                       }];
                                                       
                                                       if (error!=nil) {
                                                           ppLog(@"--loadfrom[%@]-Err=%@",urlStr,error);
                                                           [self cancelDownload];
                                                       }
                                                   }];
    
    [self.sessionTask resume];
}

-(void)startDownloadWithCompletionHandler:(void(^)(NSData *loadedData))completionHandler{
    //URLWithString貌似汉字或者空格等无法被识别,切记会导致返回nil,故需用下面的stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding转换一下
    NSString *urlStr =[self.sUrl UTF8_URL];// [self.sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    _sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                       if (error!=nil) {
                                                           ppLog(@"--loadfrom[%@]-Err=%@",[response.URL absoluteString],error);
                                                           if (completionHandler) {
                                                               completionHandler(nil);
                                                           }
                                                       }
                                                       else if (completionHandler) {
                                                           completionHandler(data);
                                                       }
                                                       
                                                   }];
    
    [self.sessionTask resume];
}

// -------------------------------------------------------------------------------
//    cancelDownload
// -------------------------------------------------------------------------------
- (void)cancelDownload
{
    if(self.sessionTask){
        [self.sessionTask cancel];
        _sessionTask = nil;
    }
}


// -------------------------------------------------------------------------------
//    handleError:error
//  Reports any error with an alert which was received from connection or loading failures.
// -------------------------------------------------------------------------------
//- (void)handleError:(NSError *)error
//{
//    NSString *errorMessage = [error localizedDescription];
//    
//    // alert user that our current record was deleted, and then we leave this view controller
//    //
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Show Top Paid Apps"
//                                                                   message:errorMessage
//                                                            preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK"
//                                                       style:UIAlertActionStyleDefault
//                                                     handler:^(UIAlertAction *action) {
//                                                         //dissmissal of alert completed
//                                                         [self cancelDownload];
//                                                     }];
//    [alert addAction:OKAction];
//}



@end
