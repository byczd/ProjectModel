//
//  ppCustomDefine.h
//  paopaoread
//
//  Created by 七七 on 2017/12/19.
//  Copyright © 2017年 paopaoread. All rights reserved.
//

#ifndef ppCustomDefine_h
#define ppCustomDefine_h

#define isNull(a) [a isKindOfClass:[NSNull class]]

//#define S_DEVICEINFO_KEY @"getdeviceinfo"
//#define S_ASOCKETREC_KEY @"ddwebsocket"

#define iOS_Version ([[UIDevice currentDevice] systemVersion])
#define iOS_buildVersion ([[UIDevice currentDevice] performSelector:@selector(buildVersion)])
#define IS_IOS12 ([iOS_Version doubleValue] >= 12.0? YES : NO)
#define IS_IOS11 ([iOS_Version doubleValue] >= 11.0? YES : NO)
#define IS_IOS10 ([iOS_Version doubleValue] >= 10.0? YES : NO)
#define IS_IOS9 ([iOS_Version doubleValue] >= 9.0? YES : NO)
#define IS_IOS8 ([iOS_Version doubleValue] >= 8.0? YES : NO)
#define IS_IOS7 ([iOS_Version doubleValue] >= 7.0? YES : NO)
#define IS_IOS6 ([iOS_Version doubleValue] >= 6.0? YES : NO)

#define NET_DELAY_TIME 25

//手机屏幕的宽度
#define  Screen_W  [[UIScreen mainScreen] bounds].size.width
//手机屏幕的高度
#define  Screen_H  [[UIScreen mainScreen] bounds].size.height
/*
4/4s:320*480
5/5c/5s:320*568
6/6s/7/8:375*667
6P/6sP/7P/8P:414*736
X:375*812
 */


#define KSC_HEIGHT     [UIScreen mainScreen].bounds.size.height/667
#define KSC_Font     [UIScreen mainScreen].bounds.size.width/375
//// 按照效果图适应比例 iphone6尺寸
#define KSC_AutoWith(x) (x/375.0*[UIScreen mainScreen].bounds.size.width)
#define KSC_AutoHeight(x) (x/667.0*[UIScreen mainScreen].bounds.size.height)

#define KD_NAVIGATION_BAR_HEIGHT (Screen_H == 812 ? 84 :64)
#define KD_STATUS_BAR_HEIGHT (Screen_H == 812 ? 44 : 20)

#define KD_TOP_PAGE_BAR_HEIGHT KSC_AutoHeight(44)//头部news类别栏toolbar高度

#define KD_BOTTOM_TAB_BAR_HEIGHT 50//底部toolbar高度：默认就是50
#define KD_TABBER_BAR_HEIGHT (Screen_H == 812 ? (KD_BOTTOM_TAB_BAR_HEIGHT+34) : KD_BOTTOM_TAB_BAR_HEIGHT) //底部toolbar+iphonex底部条高度
#define KD_BOTTOM_MARGIN (Screen_H == 812 ? 34 : 0) //iphonex 底部条

#define KD_IsiPhoneX (Screen_H == 812?YES:NO)

//SDK平台 1代表sdk是安卓的，2代表是IOS
#define PLATFORM  2
//asiVersion
//#define INNER_VER  2.0

//#define CONNECT_UNIVERSAL_URL      @"aHR0cHM6Ly93YWxsLnF1bWkuY29tL2FwaS9zZGsvY2xpY2tlZGlvcy9Db25uZWN0"

//#define QUMI_CONTENT_SUCCESS @"QUMI_CONTENT_SUCCESS"
//#define QUMI_CONNECT_SUCCESS @"QUMI_CONNECT_SUCCESS"
//#define QUMI_CONNECT_FAILED  @"QUMI_CONNECT_FAILED"

#define _initialTag 1000

//windows16进制的字符串转成UIColor
#define _RGB_HEX_2_COLOR(colorHex) ([clsCommonFunc colorWithHexString:colorHex])
#define _RGBA_HEX_2_COLOR(colorHex,alphaValue)  ([clsCommonFunc colorWithHex:colorHex alpha:alphaValue])
//返回r,g,b颜色值转换成的uicolor(注意r,g,b三个参数必须用()括起来，否则会出错)
#define _RGBA_2_COLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define _RGB_2_COLOR(r,g,b) _RGBA_2_COLOR(r,g,b,1)

#define _color_White [UIColor whiteColor]
#define _color_Black [UIColor blackColor]
#define _color_Gray [UIColor grayColor]
#define _color_Darkgray [UIColor darkGrayColor]
#define _color_Lightgray [UIColor lightGrayColor]
#define _color_Red [UIColor redColor]
#define _color_Green [UIColor greenColor]
#define _color_Blue [UIColor blueColor]
#define _color_Yellow [UIColor yellowColor]
#define _color_Cyan [UIColor cyanColor]
#define _color_Magenta [UIColor magentaColor]
#define _color_Orange [UIColor orangeColor]
#define _color_Purple [UIColor purpleColor]
#define _color_Brown [UIColor brownColor]
#define _color_Clear [UIColor clearColor]


//ToastNotification弹窗信息内容颜色类型(底景是半透明黑色)
#define _color_Info _color_White
#define _color_Warning _color_Yellow
#define _color_Error _color_Red
#define _color_Success _color_Green

#define _color_RED_1 _RGB_HEX_2_COLOR(@"e83745")
#define _color_cell_line (_RGB_HEX_2_COLOR(@"E6E6E6"))
#define _line_layer_color (_RGB_HEX_2_COLOR(@"EEEEEE"))

#define TITLE_BACK_COLOR _color_White
#define TITLE_FONT_COLOR _RGB_HEX_2_COLOR(@"E83D24")
#define TITLE_BLACK_FONT_COLOR _RGB_HEX_2_COLOR(@"171719")
#define TITLE_GRAY_FONT_COLOR _RGB_HEX_2_COLOR(@"6A696F")
#define TITLE_LGRAY_FONT_COLOR _RGB_HEX_2_COLOR(@"A3A2A7")
#define TITLE_YELLOW_FONT_COLOR  _RGB_HEX_2_COLOR(@"FDA128")
#define TITLE_LYELLOW_FONT_COLOR  _RGB_HEX_2_COLOR(@"FFEC9A")
#define TITLE_LGREEN_FONT_COLOR  _RGB_HEX_2_COLOR(@"53BFA0")
#define TITLE_DGREEN_FONT_COLOR  _RGB_HEX_2_COLOR(@"14643C")
#define BUTTON_BORDER_COLOR _RGB_HEX_2_COLOR(@"D8D8D8")
#define BUTTON_TEXT_RED_COLOR _RGB_HEX_2_COLOR(@"FF1530")


#define PAOPAO_STAR_SKY_COLOR _RGB_HEX_2_COLOR(@"627288")//627288 //2ac8db//0d1529//2a3143//ad060f
#define PAOPAO_PAGE_COLOR_DEF _RGB_HEX_2_COLOR(@"2ac8db")
#define TABLE_BK_COLOR_DEF _RGB_HEX_2_COLOR(@"f7f8f9")//@"f4f5f6"//53637b
#define TABLE_CONTENT_BACK_COLOR_DEF  _RGB_HEX_2_COLOR(@"e7e8e9")
#define TABLE_CELL_BK_COLOR_DEF [UIColor whiteColor]
#define TABLE_CELL_LINE_COLOR_DEF _RGB_HEX_2_COLOR(@"F3F3F3")

#define _APP_PATHFORRESOURCE(fileName,fileType) ([[NSBundle mainBundle] pathForResource:fileName ofType:fileType])
#define _APP_URLFORRESOURCE(fileName) [[NSBundle mainBundle] URLForResource:fileName withExtension:nil]

#define _APP_SHARE_MEMO @"每天泡一会儿，总能有收获"
#define _BUNDLE_INFODIC [[NSBundle mainBundle] infoDictionary]
//[[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]
#define _APP_DISPLAY_NAME _BUNDLE_INFODIC[@"CFBundleDisplayName"]
//[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]
#define _APP_VERSION _BUNDLE_INFODIC[@"CFBundleShortVersionString"]
//[[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"]
#define _APP_IDENTIFIER _BUNDLE_INFODIC[@"CFBundleIdentifier"]
#define _APP_EXEC_NAME _BUNDLE_INFODIC[@"CFBundleExecutable"]
#define _APP_EXEC_PATH [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] bundlePath],_APP_EXEC_NAME]

//读取本地图片(建议用前者，性能优于后者)
//定义UIImage对象1
//从资源文件中读取
#define _IMAGE(imgName,Ext) ([UIImage imageWithContentsOfFile:_APP_PATHFORRESOURCE(imgName,Ext)])
//从文件中读取
#define _IMAGE_OF_PATH(imgPath) [UIImage imageWithContentsOfFile:imgPath]
//定义UIImage对象2(从缓存读取)
#define _IMAGE_OF_NAME(fileName)  [UIImage imageNamed:fileName]

//返回指定大小系统字体uifont
#define _SYSFONT(fontSize) [UIFont systemFontOfSize:fontSize]
#define _SYSFONT_BOLD(fontSize) [UIFont boldSystemFontOfSize:fontSize]
#define _SYSFONT_ITALIC(fontSize) [UIFont italicSystemFontOfSize:fontSize]
#define _SYSFONT_WEIGHT(fontSize,fontWeight) [UIFont systemFontOfSize:fontSize weight:fontWeight]
#define _SYSFONT_FIXW(fontSize)  [UIFont fontWithName:@"Courier" size:fontSize]
//顶部状态栏高度
#define _App_StatusBar_Height [[UIApplication sharedApplication] statusBarFrame].size.height

#pragma mark- 沙箱操作
#define _DefaultUser [NSUserDefaults standardUserDefaults]
#define _DefaultUserSaveOjbectForKey(value,key) [_DefaultUser setObject:value forKey:key]
#define _DefaultUserObjectForKey(key) [_DefaultUser objectForKey:key]
#define _DefaultUserRemoveOjbectForKey(key) [_DefaultUser removeObjectForKey:key]

#define _DefaultUserSaveIntegerForKey(value,key) [_DefaultUser setInteger:value forKey:key]
#define _DefaultUserIntegerForKey(key) [_DefaultUser integerForKey:key]

#define _DefaultUserSure [_DefaultUser synchronize]

//当前设备是iPhone
#define isPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//当前设备是iPad
#define isPad   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//不分大小写比较
#define NOCASE_CMP_STR(str1,str2) ([str1 caseInsensitiveCompare:str2]==NSOrderedSame?YES:NO)

//#define myDefineWeakSelf __weak __typeof(self) weakSelf = self
//在需的地方引用 myDefineWeakSelf;
//用下面的定义更好

/**
 Synthsize a weak or strong reference.
 
 Example:
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 
 */

#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

/*
 锁定个方法，执行完毕自动解锁;
 LOCK(a_MethodName),可以将某个方法对象锁住直至方法执行完毕
 eg:
 LOCK([_currentGifImage imageViewShowFinsished]);
 eg:
 LOCK([_curImage.lb_imageBuffer setObject:img forKey:@(index)]);
 
 //需在要调用的类中，事先定义好成员变量dispatch_semaphore_t _lock;
 @interface LBPhotoBrowserManager () {
 dispatch_semaphore_t _lock;
 }
 //并在初始化接口中初始化成员变量：
 - (instancetype)init
 {
     self = [super init];
     if (self) {
     _lock = dispatch_semaphore_create(1);
     }
     return self;
 }
 
 */
#define LOCK_lock_Auto(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

/*
 上锁与解锁,eg:
Lock_self_lock();
[self _trimToCost:self.costLimit];
[self _trimToCount:self.countLimit];
[self _trimToAge:self.ageLimit];
[self _trimToFreeDiskSpace:self.freeDiskSpaceLimit];
Unlock_self_lock();
切记，当然前提是要在所引用的类模块中，定义一个类成员变量：dispatch_semaphore_t _lock;
 @interface KDLoadProManager(){
 dispatch_semaphore_t _lock; //定义成员变量，而不是属性变量
 }
并初始化：_lock = dispatch_semaphore_create(1);//初化始_lock变量
 
 如果是放在单例中初始化，则可以需定义一个静态变量:
 static dispatch_semaphore_t _globalInstancesLock;
 单例初始化：
 dispatch_once(&onceToken, ^{
 _globalInstancesLock = dispatch_semaphore_create(1);
 });
 然后在调用的地方将成员变量赋值成静态变量：
 _lock=_globalInstancesLock
 Lock_self_lock();
 ....
 Unlock_self_lock();
 
 不用宏定义，普通用法：
 dispatch_semaphore_t _lock;//定义dispatch_semaphore_t类型_lock变量
 //初始化_lock
 - (instancetype)init {
 self = [super init];
 if (!self) return nil;
 _lock = dispatch_semaphore_create(1);//初化始_lock变量
 _pathFillEvenOdd = YES;
 return self;
 }
 //然后在方法中即可调用dispatch_semaphore_wait上锁,调用dispatch_semaphore_signal解锁
 - (id)copyWithZone:(NSZone *)zone {
     YYTextContainer *one = [self.class new];
     dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
     one->_size = _size;
     one->_insets = _insets;
     one->_path = _path;
     dispatch_semaphore_signal(_lock);
     return one;
 }
 */
#define Lock_self_lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock_self_lock() dispatch_semaphore_signal(self->_lock)


#define JA5X2lzX2FwcHN0b3 300 //broken or debuging
#define _UN_NOT_FOUND 9999 //

#endif /* ppCustomDefine_h */
