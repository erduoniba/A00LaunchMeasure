//
//  QiCallTraceCore.c
//  Qi_ObjcMsgHook
//
//  Created by liusiqi on 2019/11/20.
//  Copyright © 2019 QiShare. All rights reserved.
//

#include "QiCallTraceCore.h"

#ifdef __aarch64__

#pragma mark - fishhook
#include "fishhook.h"

#include <sys/time.h>
#include <objc/message.h>
#include <objc/runtime.h>
#include <dispatch/dispatch.h>
#include <pthread.h>

static bool _call_record_enabled = true;
static uint64_t _min_time_cost = 1000; //us
static int _max_call_depth = 3;
static pthread_key_t _thread_key;
__unused static id (*orig_objc_msgSend)(id, SEL, ...);

static qiCallRecord *_qiCallRecords;
//static int otp_record_num;
//static int otp_record_alloc;
static int _qiRecordNum;
static int _qiRecordAlloc;

typedef struct thread_call_record {
    id self; //通过 object_getClass 能够得到 Class 再通过 NSStringFromClass 能够得到类名
    Class cls;
    SEL cmd; //通过 NSStringFromSelector 方法能够得到方法名
    uint64_t time; //us
    uintptr_t lr; // link register
    struct thread_call_record *caller_record; // 调用该方法的信息
} thread_call_record;

typedef struct {
    thread_call_record *stack;
    int allocated_length;
    int index;
    bool is_main_thread;
} thread_call_stack;

static inline thread_call_stack * get_thread_call_stack(void) {
    thread_call_stack *cs = (thread_call_stack *)pthread_getspecific(_thread_key);
    if (cs == NULL) {
        cs = (thread_call_stack *)malloc(sizeof(thread_call_stack));
        cs->stack = (thread_call_record *)calloc(128, sizeof(thread_call_record));
        cs->allocated_length = 64;
        cs->index = -1;
        cs->is_main_thread = pthread_main_np();
        pthread_setspecific(_thread_key, cs);
    }
    return cs;
}

static void release_thread_call_stack(void *ptr) {
    thread_call_stack *cs = (thread_call_stack *)ptr;
    if (!cs) return;
    if (cs->stack) free(cs->stack);
    free(cs);
}

static inline void push_call_record(id _self, Class _cls, SEL _cmd, uintptr_t lr) {
    thread_call_stack *cs = get_thread_call_stack();
    if (cs) {
        int nextIndex = (++cs->index);
        if (nextIndex >= cs->allocated_length) {
            cs->allocated_length += 64;
            cs->stack = (thread_call_record *)realloc(cs->stack, cs->allocated_length * sizeof(thread_call_record));
        }
        thread_call_record *newRecord = &cs->stack[nextIndex];
        newRecord->self = _self;
        newRecord->cls = _cls;
        newRecord->cmd = _cmd;
        newRecord->lr = lr;
        if (nextIndex > 0) {
            newRecord->caller_record = cs->stack;
        }
        if (cs->is_main_thread && _call_record_enabled) {
            struct timeval now;
            gettimeofday(&now, NULL);
            newRecord->time = (now.tv_sec % 100) * 1000000 + now.tv_usec;
        }
    }
}

static inline uintptr_t pop_call_record(void) {
    thread_call_stack *cs = get_thread_call_stack();
    int curIndex = cs->index;
    int nextIndex = cs->index--;
    thread_call_record *pRecord = &cs->stack[nextIndex];
    
    if (cs->is_main_thread && _call_record_enabled) {
        struct timeval now;
        gettimeofday(&now, NULL);
        uint64_t time = (now.tv_sec % 100) * 1000000 + now.tv_usec;
        if (time < pRecord->time) {
            time += 100 * 1000000;
        }
        uint64_t cost = time - pRecord->time;
        if (cost > _min_time_cost && cs->index < _max_call_depth) {
            if (!_qiCallRecords) {
                _qiRecordAlloc = 1024;
                _qiCallRecords = malloc(sizeof(qiCallRecord) * _qiRecordAlloc);
            }
            _qiRecordNum++;
            if (_qiRecordNum >= _qiRecordAlloc) {
                _qiRecordAlloc += 1024;
                _qiCallRecords = realloc(_qiCallRecords, sizeof(qiCallRecord) * _qiRecordAlloc);
            }
            qiCallRecord *log = &_qiCallRecords[_qiRecordNum - 1];
            log->cls = pRecord->cls;
            log->depth = curIndex;
            log->sel = pRecord->cmd;
            log->time = cost;
            log->lr = pRecord->lr;
            if (pRecord->caller_record != NULL) {
                qiCallRecord *caller_record = (qiCallRecord *)malloc(sizeof(qiCallRecord));
                caller_record->cls = pRecord->caller_record->cls;
                caller_record->sel = pRecord->caller_record->cmd;
                caller_record->lr = pRecord->caller_record->lr;
                log->caller_record = caller_record;
            }
        }
    }
    return pRecord->lr;
}

void before_objc_msgSend(id self, SEL _cmd, uintptr_t lr) {
    push_call_record(self, object_getClass(self), _cmd, lr);
}

uintptr_t after_objc_msgSend(void) {
    return pop_call_record();
}


//replacement objc_msgSend (arm64)
// https://blog.nelhage.com/2010/10/amd64-and-va_arg/
// http://infocenter.arm.com/help/topic/com.arm.doc.ihi0055b/IHI0055B_aapcs64.pdf
// https://developer.apple.com/library/ios/documentation/Xcode/Conceptual/iPhoneOSABIReference/Articles/ARM64FunctionCallingConventions.html
#define call(b, value) \
__asm volatile ("stp x8, x9, [sp, #-16]!\n"); \
__asm volatile ("mov x12, %0\n" :: "r"(value)); \
__asm volatile ("ldp x8, x9, [sp], #16\n"); \
__asm volatile (#b " x12\n");

#define save() \
__asm volatile ( \
"stp x8, x9, [sp, #-16]!\n" \
"stp x6, x7, [sp, #-16]!\n" \
"stp x4, x5, [sp, #-16]!\n" \
"stp x2, x3, [sp, #-16]!\n" \
"stp x0, x1, [sp, #-16]!\n");

#define load() \
__asm volatile ( \
"ldp x0, x1, [sp], #16\n" \
"ldp x2, x3, [sp], #16\n" \
"ldp x4, x5, [sp], #16\n" \
"ldp x6, x7, [sp], #16\n" \
"ldp x8, x9, [sp], #16\n" );

#define link(b, value) \
__asm volatile ("stp x8, lr, [sp, #-16]!\n"); \
__asm volatile ("sub sp, sp, #16\n"); \
call(b, value); \
__asm volatile ("add sp, sp, #16\n"); \
__asm volatile ("ldp x8, lr, [sp], #16\n");

#define ret() __asm volatile ("ret\n");

// 代码解析： https://juejin.cn/post/7076782932207075336
// 因为objc_msgSend本身是基于汇编进行实现，所以hook的方法对于objc_msgSend相关的部分都必须是基于汇编来实现。
// 用于告诉编译器生成的函数应该是“裸函数”（naked function）
// 在裸函数中，编译器不会生成任何形式的函数入口和退出代码，
// 这个函数必须非常小心地管理寄存器和其他状态，以避免破坏调用者的环境。
__attribute__((__naked__))
static void hook_Objc_msgSend(void) {
    /*
     保存objc_msgSend本身的方法栈信息。因为在objc_msgSend方法执行前，我们会执行方法before_objc_msgSend，从而对寄存器造成污染，为了确保能够正确的执行objc_msgSend方法，需要对当前的寄存器状态进行保存，等我们的方法执行完毕后，再对寄存器进行恢复，从而保证OC方法的正确执行。
     */
    save()
    
    //将objc_msgSend执行的下一个函数地址传递给before_objc_msgSend的第二个参数x0 self, x1 _cmd, x2: lr address
    __asm volatile ("mov x2, lr\n");
    __asm volatile ("mov x3, x4\n");
    
    /*
     通过blr汇编语句，执行before_objc_msgSend方法，从而在OC方法执行前，记录方法开始的时间
     作用：获取当前堆栈信息、更新记录的开始执行时间到堆栈信息中
     */
    call(blr, &before_objc_msgSend)
    
    // 恢复我们通过save()保存的objc_msgSend方法信息。
    load()
    
    // 调用原始的objc_msgSend，开始OC方法的执行。
    call(blr, orig_objc_msgSend)
    
    /*
     和之前的save()原因一样，这里是因为objc_msgSend方法执行完毕后，
     我们需要记录结束时间，会对寄存器造成污染，
     所以需要在after_objc_msgSend方法执行前，对寄存器状态进行保存。
     */
    save()
    
    /*
     通过汇编语句，调用after_objc_msgSend方法，进行方法的耗时的计算，并将函数信息和耗时存储到dtp_records中。
     找到缓存中当前堆栈信息
     读取之前缓存的执行时间
     计算出方法的耗时
     生成一条记录记录方法信息和耗时
     更新：记录该方法的调用信息，用于回溯方法调用链
     更新记录到dtp_records中
     */
    call(blr, &after_objc_msgSend)
    
    /*
     恢复寄存器x0的内容到lr中，还原hook_objc_msgSend的lr寄存器。
     */
    __asm volatile ("mov lr, x0\n");
    
    // Load original objc_msgSend return value.
    load()
    
    // return
    ret()
}


#pragma mark public

void qiCallTraceStart(void) {
    _call_record_enabled = true;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_key_create(&_thread_key, &release_thread_call_stack);
        rebind_symbols((struct rebinding[6]){
            {"objc_msgSend", (void *)hook_Objc_msgSend, (void **)&orig_objc_msgSend},
        }, 1);
    });
}

void qiCallTraceStop(void) {
    _call_record_enabled = false;
}

void qiCallConfigMinTime(uint64_t us) {
    _min_time_cost = us;
}
void qiCallConfigMaxDepth(int depth) {
    _max_call_depth = depth;
}

qiCallRecord *qiGetCallRecords(int *num) {
    if (num) {
        *num = _qiRecordNum;
    }
    return _qiCallRecords;
}

void qiClearCallRecords(void) {
    if (_qiCallRecords) {
        free(_qiCallRecords);
        _qiCallRecords = NULL;
    }
    _qiRecordNum = 0;
}

#else

#pragma mark - 模拟器

void qiCallTraceStart() {}
void qiCallTraceStop() {}
void qiCallConfigMinTime(uint64_t us) {
}
void qiCallConfigMaxDepth(int depth) {
}
qiCallRecord *qiGetCallRecords(int *num) {
    if (num) {
        *num = 0;
    }
    return NULL;
}
void qiClearCallRecords() {}

#endif
