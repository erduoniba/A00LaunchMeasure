//
//  HookCppInitMeasure.m
//  A00LaunchMeasure
//
//  Created by denglibing on 2022/5/27.
//

#import "A00CppInitMeasure.h"

#include <unistd.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <vector>
#include <objc/runtime.h>

//  排除常见系统库image
static bool isSelfDefinedImage(const char *imageName) {
    return !strstr(imageName, "/Xcode.app/") &&
    !strstr(imageName, "/Library/PrivateFrameworks/") &&
    !strstr(imageName, "/System/Library/") &&
    !strstr(imageName, "/usr/lib/");
}

// 获取主App可执行文件和添加自定义动态库对应的镜像（image）
static const struct mach_header **copyAllSelfDefinedImageHeader(unsigned int *outCount) {
    unsigned int imageCount = _dyld_image_count();
    unsigned int count = 0;
    const struct mach_header **mhdrList = NULL;
    
    if (imageCount > 0) {
        mhdrList = (const struct mach_header **)malloc(sizeof(struct mach_header *) * imageCount);
        for (unsigned int i = 0; i < imageCount; i++) {
            const char *imageName = _dyld_get_image_name(i);
            if (isSelfDefinedImage(imageName)) {
                const struct mach_header *mhdr = _dyld_get_image_header(i);
                mhdrList[count++] = mhdr;
            }
        }
        mhdrList[count] = NULL;
    }
    
    if (outCount) *outCount = count;
    
    return mhdrList;
}


static NSMutableArray *sInitInfos;
static NSTimeInterval sSumInitTime;

using namespace std;
#ifndef __LP64__
typedef uint32_t MemoryType;
#else
typedef uint64_t MemoryType;
#endif

static std::vector<MemoryType> *g_initializer;
static int g_cur_index;

struct MyProgramVars {
    const void*        mh;
    int*            NXArgcPtr;
    const char***    NXArgvPtr;
    const char***    environPtr;
    const char**    __prognamePtr;
};

// dyld的源码
typedef void (*OriginalInitializer)(int argc, const char* argv[], const char* envp[], const char* apple[], const MyProgramVars* vars);


void myInitFunc_Initializer(int argc, const char* argv[], const char* envp[], const char* apple[], const struct MyProgramVars* vars){
    ++g_cur_index;
    OriginalInitializer func = (OriginalInitializer)g_initializer->at(g_cur_index);
    
    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
    func(argc,argv,envp,apple,vars);
    CFTimeInterval end = CFAbsoluteTimeGetCurrent();
    sSumInitTime += 1000.0 * (end-start);
    
    Dl_info info;
    dladdr((void *)func, &info);
    NSArray *dli_fnames = [[NSString stringWithUTF8String:info.dli_fname] componentsSeparatedByString:@"/"];
    NSString *dli_fname = @"";
    if (dli_fnames.count > 0) {
        dli_fname = dli_fnames.lastObject;
    }
    NSString *dli_sname = [NSString stringWithUTF8String:info.dli_sname];

    NSString *cost = [NSString stringWithFormat:@"%@=%@ms", dli_sname, @(1000.0*(end - start))];
    [sInitInfos addObject:cost];
}

static void hookModInitFunc() {
    unsigned int count = 0;
    const struct mach_header **mhdrList = copyAllSelfDefinedImageHeader(&count);
    for (unsigned int i = 0; i < count; i++) {
        unsigned long size = 0;
#ifndef __LP64__
        const struct mach_header *mhdr = mhdrList[i];
        MemoryType *memory = (uint32_t*)getsectiondata(mhdr, "__DATA", "__mod_init_func", &size);
#else
        const struct mach_header_64 *mhdr = (const struct mach_header_64*)mhdrList[i];
        MemoryType *memory = (uint64_t*)getsectiondata(mhdr, "__DATA", "__mod_init_func", &size);
#endif

        Dl_info info;
        dladdr(mhdr, &info);
        NSArray *dli_fnames = [[NSString stringWithUTF8String:info.dli_fname] componentsSeparatedByString:@"/"];
        NSString *dli_fname = @"";
        if (dli_fnames.count > 0) {
            dli_fname = dli_fnames.lastObject;
        }
//        NSLog(@"macho=%@ %p memory:%p", dli_fname, info.dli_fbase, memory);
        
        for(int idx = 0; idx < size/sizeof(void*); idx++) {
            MemoryType original_ptr = memory[idx];
            g_initializer->push_back(original_ptr);
            memory[idx] = (MemoryType)myInitFunc_Initializer;
        }
    }
}


@implementation A00CppInitMeasure

+ (void)load {
    NSLog(@"A00CppInitMeasure load");
    
    sInitInfos = [NSMutableArray new];
    g_initializer = new std::vector<MemoryType>();
    g_cur_index = -1;
    hookModInitFunc();
}

+ (void)printStaticInitializerTimer {
    printf("\n\t\t\t\t\tTotal initializer time: %f ms", sSumInitTime);
    for (NSString *info in sInitInfos) {
        NSArray<NSString *> *temp = [info componentsSeparatedByString:@"="];
        if (temp.count == 2) {
            printf("\n%40s : %f ms", temp.firstObject.UTF8String, temp.lastObject.floatValue);
        }
    }
    printf("\n");
}

@end
