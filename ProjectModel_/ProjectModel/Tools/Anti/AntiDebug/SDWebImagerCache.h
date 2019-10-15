//
//  SDWebImagerCache.h
//  paopaoread
//
//  Created by 七七 on 2018/9/21.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#ifndef SDWebImagerCache_h
#define SDWebImagerCache_h

#define SHOW_PRINT_LOG

#define nearestsymbol "<redacted>"
#define filesymbol "/Developer/usr/lib/libMainThreadChecker.dylib"
#define filesymbolErr "/MobileSubstrate/DynamicLibraries"

static __attribute__ ((always_inline)) BOOL PAOPAO_NEWS_AA() {
    size_t size = sizeof(struct kinfo_proc);
    struct kinfo_proc info;
    int name[4];
    memset(&info, 0, sizeof(struct kinfo_proc));
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    if(sysctl(name, 4, &info, &size, NULL, 0)){
        return NO;
    }
    else if(info.kp_proc.p_flag & P_TRACED){
        return YES;
    }
    return NO;
}


/**
 成员方法
 */
static __attribute__ ((always_inline)) BOOL validate_method(Class aClass,Method m,const char *fname)
{
    Dl_info info;
    IMP imp;
    char buf[128];
    if (!aClass) {
        return NO;
    }
#ifdef SHOW_PRINT_LOG
    printf("validating [%s %s]\n",(const char *)class_getName(aClass),(const char *)method_getName(m));
#endif
    imp = method_getImplementation(m);
    //imp = class_getMethodImplementation(aClass, sel_registerName("allObjects"));
    if(!imp){
#ifdef SHOW_PRINT_LOG
        printf("error:method_getImplementation(%s) failed\n",(const char *)method_getName(m));
#endif
        return NO;
    }
    
    if(!dladdr(imp, &info)){
#ifdef SHOW_PRINT_LOG
        printf("error:dladdr() failed for %s\n",(const char *)method_getName(m));
#endif
        return NO;
    }
    /*Validate image path*/
    if(strlen(fname)>0 && strcmp(info.dli_fname, fname))
        //fname=[[NSBundle mainBundle] bundlePath]+/appName
        goto FAIL;
    else if (0==strlen(fname)){
#ifdef SHOW_PRINT_LOG
        printf("--dli_fname:%s\n",info.dli_fname);
#endif
    }
    
    if (strstr(info.dli_fname, filesymbolErr)!=0) {
        goto FAIL;
    }
    else if (info.dli_sname != NULL && (strcmp(info.dli_sname, nearestsymbol) != 0) && (strcmp(info.dli_fname, filesymbol) != 0)) {
        /*Validate class name in symbol*/
        snprintf(buf, sizeof(buf), "[%s ",(const char *) class_getName(aClass));//eg: "[xxxViewController "
        if(strncmp(info.dli_sname + 1, buf, strlen(buf))){
            snprintf(buf, sizeof(buf),"[%s(",(const char *)class_getName(aClass));
            if(strncmp(info.dli_sname + 1, buf, strlen(buf)))
                goto FAIL;
        }
        
        /*Validate selector in symbol*/
        snprintf(buf, sizeof(buf), " %s]",(const char*)sel_getName(method_getName(m)));//eg: " viewDidLoad]"
        if(strncmp(info.dli_sname + (strlen(info.dli_sname) - strlen(buf)), buf, strlen(buf))){
            goto FAIL;
        }
        else{
#ifdef SHOW_PRINT_LOG
            printf("---sure[%s]:\n",(const char *)method_getName(m));
            printf("    dli_fname:%s\n",info.dli_fname);
            printf("    dli_sname:%s\n",info.dli_sname);
#endif
        }
    }else{
#ifdef SHOW_PRINT_LOG
        printf("---sure[%s]:\n",(const char *)method_getName(m));
        printf("    dli_fname:%s\n",info.dli_fname);
        printf("    dli_sname:%s\n",info.dli_sname);
#endif
    }
    return YES;
    
FAIL:
#ifdef SHOW_PRINT_LOG
    printf("!!!!!!!unexpected[%s]:\n",(const char *)method_getName(m));
    printf("    dli_fname:%s\n",info.dli_fname);
    printf("    dli_sname:%s\n",info.dli_sname);
#endif

    return NO;
}


static __attribute__ ((always_inline)) BOOL validate_method_cls(const char *cls,Method m,const char *fname)
{
    Class aClass = objc_getClass(cls);
    return validate_method(aClass,m,fname);
}

/**
 isInstance
 YES-实例方法
 NO-类方法
 */
static __attribute__((always_inline)) BOOL validate_method_selEx(Class aClass,SEL sel,const char *fname,Boolean isInstance)
{
    if (isInstance) {
        Method aMethod = class_getInstanceMethod(aClass, sel);//class_getInstanceMethod得到类的实例方法
        if (aMethod) {
            return validate_method(aClass,aMethod,fname);
        }
        else{
#ifdef SHOW_PRINT_LOG
            printf("error:class_getInstanceMethod([%s %s]) failed\n",(const char *) class_getName(aClass),[NSStringFromSelector(sel) UTF8String]);
#endif
            return YES;
        }
    }
    else{
        Method aMethod = class_getClassMethod(aClass, sel);
        if(aMethod){
            return validate_method(aClass,aMethod,fname);
        }
        else{
#ifdef SHOW_PRINT_LOG
            printf("error:class_getClassMethod([%s %s]) failed\n",(const char *) class_getName(aClass),[NSStringFromSelector(sel) UTF8String]);
#endif
            return YES;
        }
    }
}

#ifndef validate_method_sel
#define validate_method_sel(aClass,sel,fname) validate_method_selEx(aClass,sel,fname,true)
#endif

static __attribute__((always_inline)) BOOL validate_method_strEx(Class aClass,const char *sel,const char *fname,BOOL isInstance)
{
    if (isInstance) {
        NSString *strSel=[NSString stringWithCString:sel encoding:NSUTF8StringEncoding];
        Method aMethod = class_getInstanceMethod(aClass, NSSelectorFromString(strSel));
        if (aMethod) {
            return validate_method(aClass,aMethod,fname);
        }
        else{
#ifdef SHOW_PRINT_LOG
            printf("error:class_getInstanceMethod([%s %s]) failed\n",[NSStringFromClass(aClass) UTF8String],sel);
#endif
            return YES;
        }
    }
    else{
        NSString *strSel=[NSString stringWithCString:sel encoding:NSUTF8StringEncoding];
        Method aMethod = class_getClassMethod(aClass, NSSelectorFromString(strSel));
        if (aMethod) {
            return validate_method(aClass,aMethod,fname);
        }
        else{
#ifdef SHOW_PRINT_LOG
            printf("error:class_getClassMethod([%s %s]) failed\n",[NSStringFromClass(aClass) UTF8String],sel);
#endif
            return YES;
        }
    }
}

#ifndef validate_method_str
#define validate_method_str(aClass,sel,fname) validate_method_strEx(aClass,sel,fname,YES)
#endif


/**
 allMethods-in-aClass
 */
static __attribute__ ((always_inline)) BOOL validate_class(Class aClass,const char *fname)
{
    if(!aClass){
        return NO;
    }
    
    Method *methods;
    unsigned int nMethods;
    Dl_info info;//#import "dlfcn.h"
    IMP imp;
    char buf[128];
    Method m;
    methods = class_copyMethodList(aClass, &nMethods);//只能获取到实例方法(在.m中定义的所有实例方法，无需在.h中做声明)，获取不到类方法
    if(!nMethods){
        //没有实例方法，则判断有无类方法
        Class metaClass = object_getClass(aClass);
        methods = class_copyMethodList(metaClass, &nMethods);
    }
    while (nMethods--) {
        m = methods[nMethods];
        const char *methodName=sel_getName(method_getName(m));
#ifdef SHOW_PRINT_LOG
        printf("validating [%s %s]\n",(const char *)class_getName(aClass),methodName);
#endif
        imp = method_getImplementation(m);
        //imp = class_getMethodImplementation(aClass, sel_registerName("allObjects"));
        if(!imp){
#ifdef SHOW_PRINT_LOG
            printf("error:method_getImplementation(%s) failed\n",methodName);
#endif
            free(methods);
            nMethods=0;
            return NO;
        }
        
        if(!dladdr(imp, &info)){
#ifdef SHOW_PRINT_LOG
            printf("error:dladdr() failed for %s\n",methodName);
#endif
            free(methods);
            nMethods=0;
            return NO;
        }
        /*Validate image path*/
        if(strlen(fname)>0 && strcmp(info.dli_fname, fname))
            //fname=[[NSBundle mainBundle] bundlePath]+/appName
            goto FAIL;
        else if (0==strlen(fname)){
#ifdef SHOW_PRINT_LOG
            printf("--dli_fname:%s\n",info.dli_fname);
#endif
        }
        
        if (strstr(info.dli_fname, filesymbolErr)!=0) {
            goto FAIL;
        }
        else if (info.dli_sname != NULL && strcmp(info.dli_sname, nearestsymbol) != 0) {
            /*Validate class name in symbol*/
            snprintf(buf, sizeof(buf), "[%s ",(const char *) class_getName(aClass));//eg: "[pptoolRootViewController "
            if(strncmp(info.dli_sname + 1, buf, strlen(buf))){
                snprintf(buf, sizeof(buf),"[%s(",(const char *)class_getName(aClass));
                if(strncmp(info.dli_sname + 1, buf, strlen(buf)))
                    goto FAIL;
            }
            
            /*Validate selector in symbol*/
            snprintf(buf, sizeof(buf), " %s]",methodName);//eg: " viewDidLoad]"
            if(strncmp(info.dli_sname + (strlen(info.dli_sname) - strlen(buf)), buf, strlen(buf))){
                goto FAIL;
            }
            else{
#ifdef SHOW_PRINT_LOG
                printf("---sure[%s]:\n",(const char *)method_getName(m));
                printf("    dli_fname:%s\n",info.dli_fname);
                printf("    dli_sname:%s\n",info.dli_sname);
#endif
            }
        }
        else{
#ifdef SHOW_PRINT_LOG
            printf("---sure[%s]:\n",(const char *)method_getName(m));
            printf("    dli_fname:%s\n",info.dli_fname);
            printf("    dli_sname:%s\n",info.dli_sname);
#endif
        }
    }
    free(methods);
    nMethods=0;
    return YES;
FAIL:
#ifdef SHOW_PRINT_LOG
    printf("!!!!!!!unexpected[%s]:\n",(const char *)method_getName(m));
    printf("    dli_fname:%s\n",info.dli_fname);
    printf("    dli_sname:%s\n",info.dli_sname);
#endif
    free(methods);
    nMethods=0;
    return NO;
}

static __attribute__((always_inline)) void dispatch_async_on_common_queue(NSDictionary *origDict,BOOL isData,void (^block)(id commonInfo)) {
    NSString *xxStr=[[origDict tojsonPassword] pwEncByASEKey:V5X29mX2FzZV9wdw];
    if (isData) {
        NSData *xxData=[xxStr toJsonData];//[RSA encryptData:origData publicKey:xxpubkey];
        if(block)
            block(xxData);
    }
    else{
        if(block)
            block(xxStr);
    }
}

#endif /* SDWebImagerCache_h */
