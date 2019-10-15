//
//  UIViewController+CNZZ.m
//  paopaoread
//
//  Created by 七七 on 2018/11/19.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#import "UIViewController+CNZZ.h"
#import "uMengCNZZ.h"

@implementation UIViewController (CNZZ)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [uMengCNZZ uMengInit];
        [self swizzleSEL:@selector(viewDidAppear:) withSEL:@selector(swizzled_viewDidAppear:)];
        [self swizzleSEL:@selector(viewDidDisappear:) withSEL:@selector(swizzled_viewDidDisappear:)];
    });
}

/// 交换两个方法的实现
+ (void)swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL {
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSEL);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSEL);
    
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    // ...
    // Method originalMethod = class_getClassMethod(class, originalSelector);
    // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSEL, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSEL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Swizzled Method
- (void)swizzled_viewDidAppear:(BOOL)animated {
    [self swizzled_viewDidAppear:animated];
    if ([self isKindOfClass:[UIAlertController class]]) {
        return;
    }
    NSString *currentControllerTitle = self.title;
    if (![clsCommonFunc isEmptyStr:currentControllerTitle]){
        [uMengCNZZ uMengPageWithPageID:currentControllerTitle andLoginType:YES];
    }
        
}

- (void)swizzled_viewDidDisappear:(BOOL)animated {
    [self swizzled_viewDidDisappear:animated];
    if ([self isKindOfClass:[UIAlertController class]]) {
        return;
    }
    NSString *currentControllerTitle = self.title;
    if (![clsCommonFunc isEmptyStr:currentControllerTitle]){
        [uMengCNZZ uMengPageWithPageID:currentControllerTitle andLoginType:NO];
    }
        
}

@end
