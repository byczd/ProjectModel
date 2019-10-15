//
//  QMReachability.h
//  qm
//
//  Created by qm on 14-7-30.
//  Copyright (c) 2014年 qm. All rights reserved.
//


#import <Foundation/Foundation.h>

#import <SystemConfiguration/SystemConfiguration.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#if OS_OBJECT_USE_OBJC
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

extern NSString *const QMkReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, NetworkStatus) {
    // Apple NetworkStatus Compatible Names.
    NotReachable = 0,
    ReachableViaWiFi = 2,
    ReachableViaWWAN = 1
};

@class QMReachability;

typedef void (^NetworkReachable)(QMReachability * reachability);
typedef void (^NetworkUnreachable)(QMReachability * reachability);

@interface QMReachability : NSObject
@property (nonatomic, copy) NetworkReachable    reachableBlock;
@property (nonatomic, copy) NetworkUnreachable  unreachableBlock;


@property (nonatomic, assign) BOOL reachableOnWWAN;

+(QMReachability*)reachabilityWithHostname:(NSString*)hostname;
// This is identical to the function above, but is here to maintain compatibility with Apples original code. (see .m)
//2个一样方法(为了保持与Apple代码的一致性)
+(QMReachability*)reachabilityWithHostName:(NSString*)hostname;
+(QMReachability*)reachabilityForInternetConnection;
+(QMReachability*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;
+(QMReachability*)reachabilityForLocalWiFi;
+(BOOL)networkAvailable;
-(QMReachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

-(BOOL)startNotifier;
-(void)stopNotifier;

-(BOOL)isReachable;
-(BOOL)isReachableViaWWAN;
-(BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired; // Identical DDG variant.
-(BOOL)connectionRequired; // Apple's routine.
// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand;
// Is user intervention required?
-(BOOL)isInterventionRequired;

-(NetworkStatus)currentReachabilityStatus;
-(SCNetworkReachabilityFlags)reachabilityFlags;
-(NSString*)currentReachabilityString;
-(NSString*)currentReachabilityFlags;

@end
