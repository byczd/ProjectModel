//
//  musicInfoLoadPro.m
//  doudouComeOn
//
//  Created by 七七 on 2018/1/24.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#import "AFURLRequestManager.h"


@interface AFURLRequestManager(){
    dispatch_semaphore_t _lock;
}
@property (nonatomic, strong) NSMutableDictionary *theLoadingInfoDict;
@end

@implementation AFURLRequestManager

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
    Lock_self_lock();//添加和删除时都用的同一个_theLoadingInfoDict，必须进行上锁操作，否则有可能崩溃
    NSString *md5Key=[url QMmd5];
    AFURLRequestLoader *downloader=nil;
    if (_theLoadingInfoDict) {
        downloader = (self.theLoadingInfoDict)[md5Key];
    }
    else{
        _theLoadingInfoDict=[NSMutableDictionary dictionaryWithCapacity:0];
    }
    Unlock_self_lock();
    
    if (downloader == nil)
    {
        @weakify(self);
        downloader = [[AFURLRequestLoader alloc] initWithUrl:url];
        [downloader setCompletionHandler:^(NSData *theData){
            LOCK_lock_Auto([weak_self.theLoadingInfoDict removeObjectForKey:md5Key]);
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
                if(weak_self.delegate && [weak_self.delegate respondsToSelector:@selector(loadDataIntoDefaultUserNotiWithUrl:andData:)]) {
                    //不便于使用handler的地方，使用_delegate来通知
                    [weak_self.delegate loadDataIntoDefaultUserNotiWithUrl:url andData:theData];
                }
            }
            else{
                debugLog(@"---!!!startLoad-Fail[%@]",url);
                if(weak_self.delegate && [weak_self.delegate respondsToSelector:@selector(loadDataIntoDefaultUserNotiWithUrl:andData:)]) {
                    //不便于使用handler的地方，使用_delegate来通知
                    [weak_self.delegate loadDataIntoDefaultUserNotiWithUrl:url andData:nil];
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
    AFURLRequestLoader *downloader=nil;
    if (_theLoadingInfoDict) {
        downloader = (self.theLoadingInfoDict)[md5Key];
    }
    else{
        _theLoadingInfoDict=[NSMutableDictionary dictionaryWithCapacity:0];
    }
    Unlock_self_lock();
    
    if (downloader == nil)
    {
        @weakify(self);
        downloader = [[AFURLRequestLoader alloc] initWithUrl:url];
        [downloader setCompletionHandler:^(NSData *theData){
            LOCK_lock_Auto([weak_self.theLoadingInfoDict removeObjectForKey:md5Key]);
            NSString *filePath=[AFURLRequestManager getLocalSavePathForUrl:url newDicWhenNoExist:YES];
            if (theData && [theData writeToFile:filePath atomically:YES]){
                if (handler) {
                    handler(filePath);
                }
            }
            else{
                debugLog(@"-----!!!startLoad[%@]>Fail-filePath=%@",url,filePath);
                if (handler) {
                    handler(nil);
                }
            }
            if(weak_self.delegate && [weak_self.delegate respondsToSelector:@selector(loadDataIntoCacheNotiWithUrl:andIndexPath:)]) {
                [weak_self.delegate loadDataIntoCacheNotiWithUrl:url andIndexPath:theIndexpath];
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
    NSString *urlStr = [url UTF8_URL];
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
    
    AFURLRequestLoader *downloader = [[AFURLRequestLoader alloc] initWithUrl:surl];
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
            debugLog(@"loadOverFor>%@",surl);
        }
        else{
            debugLog(@"---!!!startLoad-Fail[%@]",surl);
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
    
    NSString *filePath =[AFURLRequestManager getLocalSavePathForUrl:url newDicWhenNoExist:YES];
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

-(void)getJsonData:(NSString *)urlStr withparam:(NSDictionary *)fieldDict completionHandler:(void(^)(NSData *urlData,NSInteger statusCode))completionblk{
#ifndef PP_ANTI_DUG
    UMSOCIAL_MGR_ALL;
#endif
    //传输加密信息，放到调用层处理
    debugLog(@"========gtData_from[%@]",urlStr);
    NSURL *url = [NSURL URLWithString:[urlStr urlEncode]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:NET_DELAY_TIME];
    if (fieldDict) {
        //是否有附加信息
        //    [request addValue:@"2" forHTTPHeaderField:@"PLATFORM"];
        for (NSString *perFieldName in fieldDict) {
            NSString *objStr=[fieldDict objectForKey:perFieldName];
            [request addValue:objStr forHTTPHeaderField:perFieldName];
        }
    }
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    __weak typeof(urlSession) weakSession = urlSession;
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
            if (data && [data length] > 0 && error == nil) {
                if (completionblk){
                    completionblk(data,urlResponse.statusCode);
                }
//                NSString *strjson = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//                NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableLeaves error:nil];
            }else{
                if(completionblk)
                    completionblk(nil,urlResponse.statusCode);
            }
            if (weakSession) {
                [weakSession finishTasksAndInvalidate];
            }
        });
    }];
    
    [task resume];
    
}

-(void)postFormData:(NSDictionary *)formDict withJsonDataType:(BOOL)isJsonData todest:(NSString *)urlStr completionHandler:(void(^)(NSData *urlData))completionblk{
    debugLog(@"========postFormData_TO[%@]",urlStr);
    NSString *ptUrlStr=[urlStr UTF8_URL];
    NSURL *url = [NSURL URLWithString:ptUrlStr];
    NSString *theBoundary = @"myFormBoundary";//分隔符，可以是任意随机字符串
//    ---------post表单数据注意点：
//    1.我们需要自己设置Content-Type和Content-Length
//    2.在表单中，boundary是一个很重要的东西，他可以是一个随机的字符串，它是将参数隔开的标志，但需要注意的是，这个标志在整个表单中必须一致
//    3.我们在设置参数时，需要指定Content-Disposition，其中，name为参数对于的key值。如果参数为文件格式，同时还要指定filename以及Content-Type
//    4.其中最重要的一点，就是在设置参数的value时，必须在值之前加入一个换行。在一个参数结束时也要加个换行；同时，在http中，换行为\r\n
//    5.参数的分隔是以"--"拼接上boundary，然后拼接上"\r\n"来实现的，同时，在所有参数结束后，需要以"--"拼接boundary再拼接"--"来结束。
    //访问请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    //用来拼接参数
    NSMutableData *data = [NSMutableData data];
    for (NSString *perKey in formDict) {
        //拼接每一个参数(参数的分隔是以"--"拼接上boundary,然后拼接上"\r\n"来实现的)
        [data appendData:[[NSString stringWithFormat:@"--%@\r\n", theBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //拼接参数名(post表单数据时，key需要加上双引号)
        [data appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data;name=\"%@\"\r\n",perKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];//在设置参数的value时，必须在值之前加入一个换行。
        //拼接参数值
        if (isJsonData) {
            //数据格式需转成json格式数据
            NSData *perJsonData =[formDict objectForKey:perKey];//每个值为已转换好的json格式的NSData数据
            [data appendData:perJsonData];
        }
        else{
            //默认为post-string格式数据
            NSString *perStrData=[formDict objectForKey:perKey];//string类型数据，也需转成NSData类型
            [data appendData:[perStrData dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];//每个参数结束也要加上换行
    }
//    //拼接第一个参数
//    [data appendData:[[NSString stringWithFormat:@"--%@\r\n", theBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    //拼接参数名
//    [data appendData:[@"Content-Disposition:form-data;name=\"Data\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    //拼接参数值
//    NSString *postParams =[self modelToString];// [NSString stringWithFormat:@"{\"akid\":\"doudou\",\"aks\":\"2f41eb0663a765\"}"];
//    NSData *jsonData =[postParams dataUsingEncoding:NSUTF8StringEncoding];
//    [data appendData:jsonData];
////    [data appendData:[@"doudou" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//
//    //拼接第二个参数
//    [data appendData:[[NSString stringWithFormat:@"--%@\r\n", theBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    //拼接参数名
//    [data appendData:[@"Content-Disposition:form-data;name=\"aks\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    //拼接参数值
//    [data appendData:[@"2f41eb0663a765" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    ----------如果是上传一个文件的话，可以这样写：
     //拼接参数名
//    [data appendData:[@"Content-Disposition:form-data;name=\"file\";filename=\"myText.txt\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //拼接文件类型
//    [data appendData:[@"Content-Type:text/plain" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //拼接参数值
//    [data appendData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"myText" ofType:@"txt"]]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //拼接结束标志(在所有参数结束后，需要以"--"拼接boundary再拼接"--"来结束。)
    [data appendData:[[NSString stringWithFormat:@"--%@--", theBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

    request.HTTPBody = data;
    [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@", theBoundary] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;//NSURLRequestReloadIgnoringLocalCacheData
    config.networkServiceType = NSURLNetworkServiceTypeDefault;
    config.timeoutIntervalForRequest = NET_DELAY_TIME;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    __weak typeof(urlSession) weakSession = urlSession;
    NSURLSessionDataTask *task2 = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if (urlResponse && urlResponse.statusCode==200) {
            if(completionblk)
                completionblk(data);
        }
        else if (completionblk)
            completionblk(nil);
        if (weakSession) {
            [weakSession finishTasksAndInvalidate];
        }
    }];

    [task2 resume];
}

-(void)postJsonData:(NSDictionary *)jsonDict forKey:(NSString *)theKey todest:(NSString *)urlStr completionHandler:(void(^)(NSData *urlData))completionblk{
    NSLog(@"========postJsonData_TO[%@]",urlStr);
    NSString *ptUrlStr=[urlStr UTF8_URL];
    NSURL *url = [NSURL URLWithString:ptUrlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod =@"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (jsonDict) {
        if (theKey) {
            NSMutableDictionary *OtherDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            [OtherDic setValue:jsonDict forKey:theKey];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:OtherDic options:NSJSONWritingPrettyPrinted error:nil];
            [request setHTTPBody:jsonData];
            [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length]forHTTPHeaderField:@"Content-Length"];
        }
        else{
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:nil];
            [request setHTTPBody:jsonData];
            [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length]forHTTPHeaderField:@"Content-Length"];
        }
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    config.networkServiceType = NSURLNetworkServiceTypeDefault;
    config.timeoutIntervalForRequest = NET_DELAY_TIME;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    __weak typeof(urlSession) weakSession = urlSession;
    NSURLSessionDataTask *task2 = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if (urlResponse && urlResponse.statusCode==200) {
            if(completionblk)
                completionblk(data);
        }
        else if (completionblk)
            completionblk(nil);
        if (weakSession) {
            [weakSession finishTasksAndInvalidate];
        }
    }];
    [task2 resume];
}

-(void)postJsonData:(NSDictionary *)jsonDict forKey:(NSString *)theKey todest:(NSString *)urlStr withheadInfo:(NSDictionary *)headInfo completionHandler:(void(^)(NSData *urlData))completionblk{
    debugLog(@"========ptJson[%@]",urlStr);
    NSString *ptUrlStr=[urlStr UTF8_URL];
    NSURL *url = [NSURL URLWithString:ptUrlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod =@"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (jsonDict) {
        if (theKey) {
            NSMutableDictionary *OtherDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            [OtherDic setValue:jsonDict forKey:theKey];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:OtherDic options:NSJSONWritingPrettyPrinted error:nil];
            [request setHTTPBody:jsonData];
            [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length]forHTTPHeaderField:@"Content-Length"];
        }
        else{
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:nil];
            [request setHTTPBody:jsonData];
            [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length]forHTTPHeaderField:@"Content-Length"];
        }
    }
    if (headInfo && [headInfo count]>0) {
        for (NSString *theKey in headInfo) {
            NSString *theValue=[headInfo objectForKey:theKey];
            [request setValue:theValue forHTTPHeaderField:theKey];
        }
    }
    NSURLSessionConfiguration *config =[NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    config.networkServiceType = NSURLNetworkServiceTypeDefault;
    config.timeoutIntervalForRequest = NET_DELAY_TIME;
    //在蜂窝网络情况下是否继续请求（上传或下载）
//    config.allowsCellularAccess = NO;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    __weak typeof(urlSession) weakSession = urlSession;
    //或者直接用urlSession=[NSURLSession sharedSession] //获取全局的NSURLSession对象。在iPhone的所有app共用一个全局session.就不需要对urlSession进行finishTasksAndInvalidate释放
    NSURLSessionDataTask *task2 = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if (urlResponse && urlResponse.statusCode==200) {
            if(completionblk)
//                dispatch_async(dispatch_get_main_queue(), ^{//若在返回block中需更新UI，//dispatch_async开启一个异步操作//dispatch_get_main_queue()通知主线程刷新
                completionblk(data);
//                });
        }
        else if (completionblk)
            completionblk(nil);
        if (weakSession) {
            [weakSession finishTasksAndInvalidate];
        }
    }];
    [task2 resume];
}

//#pragma mark-获取关键词排名
//test-post-form-data
-(void)test_to_PostFormData{
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:@"doudou",@"akid", @"2f41eb0663a765",@"aks",nil];
    NSString *strContent=[NSString stringWithFormat:@"{\"akid\":\"%@\", \"aks\":\"%@\"}",@"doudou",@"2f41eb0663a765"];
    NSString *url=@"http://dev.web.doudou.com/backendapi/common/getParams";
    NSData *jsonData =[strContent dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [self postFormData:[NSDictionary dictionaryWithObjectsAndKeys:jsonData,@"Data", nil] withJsonDataType:YES todest:url completionHandler:^(NSData *urlData) {
        NSDictionary *tmpDict=[NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"tmpDict=%@",tmpDict);
    }];
    
    NSString *urlCDS=@"http://116.62.175.233:50022/token";
    [self postFormData:dict withJsonDataType:NO todest:urlCDS completionHandler:^(NSData *urlData) {
        NSString *str  =[[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"stoken=%@",str);
    }];
}

@end


@interface AFURLRequestLoader()
// the queue to run our "ParseOperation"
//@property (nonatomic, strong) NSOperationQueue *queue;

// url session task
@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;
@property (nonatomic, strong) NSString *sUrl;
@end

@implementation AFURLRequestLoader

- (instancetype)initWithUrl:(NSString *)url{
    if (self=[super init]) {
        self.sUrl=url;
    }
    return self;
}

- (void)startDownload
{
    //URLWithString貌似汉字或者空格等无法被识别,切记会导致返回nil,故需用下面的stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding转换一下
    NSString *urlStr = [self.sUrl UTF8_URL];
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
                                                           debugLog(@"--loadfrom[%@]-Err=%@",urlStr,error);
                                                           [self cancelDownload];
                                                       }
                                                   }];
    
    [self.sessionTask resume];
}

-(void)startDownloadWithCompletionHandler:(void(^)(NSData *loadedData))completionHandler{
    //URLWithString貌似汉字或者空格等无法被识别,切记会导致返回nil,故需用下面的stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding转换一下
    NSString *urlStr = [self.sUrl UTF8_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    _sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                       if (error!=nil) {
                                                           debugLog(@"--loadfrom[%@]-Err=%@",[response.URL absoluteString],error);
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
