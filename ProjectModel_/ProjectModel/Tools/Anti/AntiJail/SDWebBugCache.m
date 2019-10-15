#include "SDWebBugCache.h"
#import <UIKit/UIKit.h>
#include <sys/syscall.h>
//#include <sys/sysctl.h>
#include <unistd.h>


#if !defined(SYS_syscall)
#define SYS_syscall 0
#endif



static __attribute__((always_inline)) void asm_exit() {
#ifdef __arm64__
    __asm__("mov X0, #0\n"
            "mov w16, #1\n"
            "svc #0x80\n"
            "mov x1, #0\n"
            "mov sp, x1\n"
            "mov x29, x1\n"
            "mov x30, x1\n"
            "ret");
#endif
}

typedef int (*PTRACE_T)(int request, pid_t pid, caddr_t addr, int data);
static void _clear_cache_001() {
    void *handle = dlopen(NULL, RTLD_GLOBAL | RTLD_NOW);
    PTRACE_T ptrace_ptr = dlsym(handle, s_ppppddd);
    ptrace_ptr(31, 0, 0, 0);
}

static __attribute__((always_inline)) void _clear_cache_003() {
#ifdef __arm64__
    __asm__("mov X0, #31\n"
            "mov X1, #0\n"
            "mov X2, #0\n"
            "mov X3, #0\n"
            "mov w16, #26\n"
            "svc #0x80");
#endif
}

static __attribute__((always_inline)) void _clear_cache_004() {
#ifdef __arm64__
    __asm__("mov X0, #26\n"
            "mov X1, #31\n"
            "mov X2, #0\n"
            "mov X3, #0\n"
            "mov X4, #0\n"
            "mov w16, #0\n"
            "svc #0x80");
#endif
}


void _clear_cache_005() { syscall(26, 31, 0, 0, 0); }



#include <unistd.h>
void _clear_cache_007() {
    if (isatty(1)) {
        asm_exit();
    } else {
    }
}

#include <sys/ioctl.h>
void _clear_cache_008() {
    if (!ioctl(1, TIOCGWINSZ)) {
        asm_exit();
    } else {
    }
}

void cxx_destructCache() {
    _clear_cache_001();
    _clear_cache_003();
    _clear_cache_003();
    _clear_cache_005();
    _clear_cache_007();
    _clear_cache_008();
    _clear_cache_isatty;
    _clear_cache_ioctl;
}
