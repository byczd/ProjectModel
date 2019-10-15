//
//  MJBugDefines.h
//
//
//  Created by 七七 on 2018/9/21.
//  Copyright © 2018年 paopaoread. All rights reserved.
//

#ifndef MJBugDefines_h
#define MJBugDefines_h

#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <sys/sysctl.h>
#include <unistd.h>
#import <sys/stat.h>
#import "dlfcn.h"
#import <objc/runtime.h>
#include <sys/types.h>

//-----test.begin
#define PP_ANTI_DUG
//-------test.end


#define UDTID_CRASH_ALL exit(-1)

#define UDTID_CRASH_64 do{\
__asm__("mov X0, #0\n"\
"mov w16, #1\n"\
"svc #0x80\n"\
"mov x1, #0\n"\
"mov sp, x1\n"\
"mov x29, x1\n"\
"mov x30, x1\n"\
"ret");\
}while(0)


#define _clear_cache_isatty do{\
if (isatty(1)) {\
UDTID_CRASH_ALL;\
}\
}while(0)


#define _clear_cache_ioctl do{\
if (!ioctl(1, TIOCGWINSZ)) {\
UDTID_CRASH_ALL;\
}\
else{}\
}while(0)


#define UMESSAGE_32 do{\
asm volatile( \
"mov r0,#31\n" \
"mov r1,#0\n" \
"mov r2,#0\n" \
"mov r12,#26\n" \
"svc #80\n" \
);\
}while(0)

#define UMESSAGE_64 do{\
asm volatile( \
"mov x0,#26\n" \
"mov x1,#31\n" \
"mov x2,#0\n" \
"mov x3,#0\n" \
"mov x16,#0\n" \
"svc #128\n" \
);\
}while(0)


#define UTDID_SB_64 do{\
__asm__("mov X0, #31\n"\
"mov X1, #0\n"\
"mov X2, #0\n"\
"mov X3, #0\n"\
"mov w16, #26\n"\
"svc #0x80");\
}while(0)


#define UTDVICE_FB_64 do{\
__asm__("mov X0, #26\n"\
"mov X1, #31\n"\
"mov X2, #0\n"\
"mov X3, #0\n"\
"mov X4, #0\n"\
"mov w16, #0\n"\
"svc #0x80");\
}while(0)

#define UMSOCIAL_MGR_ALL do{ \
syscall(26,31,0,0,0);\
}while(0)


#define s_ppppddd [[@"cHRyYWNl" QMBase64Decode] UTF8String]

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#define QQAPI_EXTEND_ALL do{\
void *handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);\
ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(handle, s_ppppddd);\
ptrace_ptr(31, 0, 0, 0);\
}while(0)



#endif /* MJBugDefines_h */
