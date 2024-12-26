//
//  A00LoadMeasure.m
//  A00LaunchMeasure
//
//  Created by denglibing on 2022/5/23.
//

#import "A00LoadMeasure.h"

#include <objc/message.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <objc/runtime.h>
#include <mach-o/getsect.h>

@interface A00LoadInfo : NSObject
@property (copy, nonatomic, readonly) NSString *clsname;
@property (copy, nonatomic, readonly) NSString *catname;
@property (assign, nonatomic, readonly) CFAbsoluteTime start;
@property (assign, nonatomic, readonly) CFAbsoluteTime end;
@property (assign, nonatomic, readonly) CFAbsoluteTime duration;
@end

NSArray <A00LoadInfoWrapper *> *LMLoadInfoWappers = nil;
static NSInteger LMAllLoadNumber = 0;

// copy from objc-runtime-new.h
#pragma mark - objc-runtime
struct lm_method_t {
    SEL name;
    const char *types;
    IMP imp;
};

struct lm_method_list_t {
    uint32_t entsizeAndFlags;
    uint32_t count;
    struct lm_method_t first;
};

struct lm_category_t {
    const char *name;
    Class cls;
    struct lm_method_list_t *instanceMethods;
    struct lm_method_list_t *classMethods;
    // ignore others
};
#pragma mark


#pragma mark - 类别相关方法
// 获取类别所属的类
static Class cat_getClass(Category cat) {
    return ((struct lm_category_t *)cat)->cls;
}

static const char *cat_getName(Category cat) {
    return ((struct lm_category_t *)cat)->name;
}

// 获取类别中load的方法IMP
static IMP cat_getLoadMethodImp(Category cat) {
    struct lm_method_list_t *list_info = ((struct lm_category_t *)cat)->classMethods;
    if (!list_info) return NULL;
    
    struct lm_method_t *method_list = &list_info->first;
    uint32_t count = list_info->count;
    for (int i = 0; i < count; i++) {
        struct lm_method_t method =  method_list[i];
        const char *name = sel_getName(method.name);
        if (0 == strcmp(name, "load")) {
            return method.imp;
        }
    }
    
    return nil;
}
#pragma mark

static void printLoadInfoWappers(void);

// 包含load方法的类或者类别信息的类
@interface A00LoadInfo () {
    @package
    SEL _nSEL;
    IMP _oIMP;
    CFAbsoluteTime _start;
    CFAbsoluteTime _end;
}

- (instancetype)initWithClass:(Class)cls;
- (instancetype)initWithCategory:(Category)cat;
@end

@implementation A00LoadInfo
- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    if (self = [super init]) {
        // DO NOT use cat->cls! cls may be cat->cls->isa instead
        // 对于 category ，既然无法 remapClass (私有函数) ，就直接拿 cat->cls->isa 的 name
        // 对于 class ，为了和 category 统一，直接取 meta class name
        // 由于 meta name 和 name 相同，反射时再根据 meta name 取 class
        _clsname = [NSString stringWithCString:object_getClassName(cls) encoding:NSUTF8StringEncoding];
    }
    return self;
}
- (instancetype)initWithCategory:(Category)cat {
    if (!cat) return nil;
    Class cls = cat_getClass(cat);
    if (self = [self initWithClass:cls]) {
        _catname = [NSString stringWithCString:cat_getName(cat) encoding:NSUTF8StringEncoding];
        _oIMP = cat_getLoadMethodImp(cat);
    }
    return self;
}

- (CFAbsoluteTime)duration {
    return _end - _start;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@) duration: %f ms", _clsname, _catname, (_end - _start) * 1000];
}
@end


// 记录所以load方法的类和类别，管理类
@interface A00LoadInfoWrapper () {
    @package
    NSMutableDictionary <NSNumber *, A00LoadInfo *> *_infoMap;
}

@property (assign, nonatomic, readonly) Class cls;
@property (copy, nonatomic, readonly) NSArray <A00LoadInfo *> *infos;

- (instancetype)initWithClass:(Class)cls;
- (void)addLoadInfo:(A00LoadInfo *)info;
- (A00LoadInfo *)findLoadInfoByImp:(IMP)imp;
- (A00LoadInfo *)findClassLoadInfo;
@end

@implementation A00LoadInfoWrapper
- (instancetype)initWithClass:(Class)cls {
    if (self = [super init]) {
        _infoMap = [NSMutableDictionary dictionary];
        _cls = cls;
    }
    return self;
}

- (void)addLoadInfo:(A00LoadInfo *)info {
    _infoMap[@((uintptr_t)info->_oIMP)] = info;
}

- (A00LoadInfo *)findLoadInfoByImp:(IMP)imp {
    return _infoMap[@((uintptr_t)imp)];
}

- (A00LoadInfo *)findClassLoadInfo {
    for (A00LoadInfo *info in _infoMap.allValues) {
        if (!info.catname) {
            return info;
        }
    }
    return nil;
}

- (NSArray<A00LoadInfo *> *)infos {
    return _infoMap.allValues;
}

+(void)printLoadInfoWappers {
    printLoadInfoWappers();
}

@end


#pragma mark - Step1 获取需要监测的 image
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
                printf("imageName: %s", imageName);
                const struct mach_header *mhdr = _dyld_get_image_header(i);
                mhdrList[count++] = mhdr;
            }
        }
        mhdrList[count] = NULL;
    }
    
    if (outCount) *outCount = count;
    
    return mhdrList;
}
#pragma mark


#pragma mark - Step2 获取定义了 +load 方法的类和分类
// 过滤特殊类
static bool shouldRejectClass(NSString *name) {
    if (!name) return true;
    NSArray *rejectClses = @[@"__ARCLite__"];
    return [rejectClses containsObject:name];
}

// 通过 mach_header和sectionname 来获取数据，__objc_nlcatlist：获取类别列表；__objc_nlclslist获取类列表
static void *getDataSection(const struct mach_header *mhdr, const char *sectname, size_t *bytes) {
    void *data = getsectiondata((void *)mhdr, "__DATA", sectname, bytes);
    if (!data) {
        data = getsectiondata((void *)mhdr, "__DATA_CONST", sectname, bytes);
    }
    if (!data) {
        data = getsectiondata((void *)mhdr, "__DATA_DIRTY", sectname, bytes);
    }
    return data;
}

// 直接通过 getsectiondata 函数，读取编译时期写入 mach-o 文件 DATA 段的 __objc_nlclslist 和 __objc_nlcatlist 节，这两节分别用来保存 no lazy class 列表和 no lazy category 列表，所谓的 no lazy 结构，就是定义了 +load 方法的类或分类
static NSArray <A00LoadInfo *> *getNoLazyArray(const struct mach_header *mhdr) {
    NSMutableArray *noLazyArray = [NSMutableArray new];
    unsigned long bytes = 0;
    Category *cats = getDataSection(mhdr, "__objc_nlcatlist", &bytes);
    for (unsigned int i = 0; i < bytes / sizeof(Category); i++) {
        A00LoadInfo *info = [[A00LoadInfo alloc] initWithCategory:cats[i]];
        if (!shouldRejectClass(info.clsname)) [noLazyArray addObject:info];
    }
    
    bytes = 0;
    Class *clses = (Class *)getDataSection(mhdr, "__objc_nlclslist", &bytes);
    for (unsigned int i = 0; i < bytes / sizeof(Class); i++) {
        A00LoadInfo *info = [[A00LoadInfo alloc] initWithClass:clses[i]];
        if (!shouldRejectClass(info.clsname)) [noLazyArray addObject:info];
    }
    return noLazyArray;
}
#pragma mark


#pragma mark - Step3 hook 类和分类的 +load 方法
// 生成随机的SEL，用于和类本身的load交换，然后统计load耗时
static SEL getRandomLoadSelector(void) {
    return NSSelectorFromString([NSString stringWithFormat:@"_lh_hooking_%x_load", arc4random()]);
}

// 排序打印load方法耗时
static void printLoadInfoWappers(void) {
    NSMutableArray *infos = [NSMutableArray array];
    for (A00LoadInfoWrapper *infoWrapper in LMLoadInfoWappers) {
        [infos addObjectsFromArray:infoWrapper.infos];
    }
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO];
    [infos sortUsingDescriptors:@[descriptor]];
    
    CFAbsoluteTime totalDuration = 0;
    for (A00LoadInfo *info in infos) {
        totalDuration += info.duration;
    }
    printf("\n\t\t\t\t\t\t\tTotal load time: %f ms", totalDuration * 1000);
    for (A00LoadInfo *info in infos) {
        NSString *clsname = [NSString stringWithFormat:@"%@", info.clsname];
        if (info.catname) clsname = [NSString stringWithFormat:@"%@(%@)", clsname, info.catname];
        printf("\n%40s load time: %f ms", [clsname cStringUsingEncoding:NSUTF8StringEncoding], info.duration * 1000);
    }
    printf("\n");
}

// 方法交换，生成随机SEL和load进行交换
static void swizzleLoadMethod(Class cls, Method method, A00LoadInfo *info) {
retry:
    do {
        SEL hookSel = getRandomLoadSelector();
        Class metaCls = object_getClass(cls);
        // 方法交换，并且执行原方法，统计load方法的耗时
        IMP hookImp = imp_implementationWithBlock(^ {
            info->_start = CFAbsoluteTimeGetCurrent();
            ((void (*)(Class, SEL))objc_msgSend)(cls, hookSel);
            info->_end = CFAbsoluteTimeGetCurrent();
//            if (!--LMAllLoadNumber) printLoadInfoWappers();
        });
        
        BOOL didAddMethod = class_addMethod(metaCls, hookSel, hookImp, method_getTypeEncoding(method));
        if (!didAddMethod) goto retry;
        
        info->_nSEL = hookSel;
        Method hookMethod = class_getInstanceMethod(metaCls, hookSel);
        method_exchangeImplementations(method, hookMethod);
    } while(0);
}

// 获得了拥有 +load 方法的类和分类，就可以 hook 对应的 +load 方法了
static void hookAllLoadMethods(A00LoadInfoWrapper *infoWrapper) {
    unsigned int count = 0;
    Class metaCls = object_getClass(infoWrapper.cls);
    Method *methodList = class_copyMethodList(metaCls, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        SEL sel = method_getName(method);
        const char *name = sel_getName(sel);
        if (!strcmp(name, "load")) {
            IMP imp = method_getImplementation(method);
            A00LoadInfo *info = [infoWrapper findLoadInfoByImp:imp];
            if (!info) {
                info = [infoWrapper findClassLoadInfo];
                if (!info) continue;
            }
            
            swizzleLoadMethod(infoWrapper.cls, method, info);
        }
    }
    free(methodList);
}

// 获取app中所有有load方法的信息，key：类名，value：load相关信息（数组）
NSDictionary <NSString *, A00LoadInfoWrapper *> *prepareMeasureForMhdrList(const struct mach_header **mhdrList, unsigned int  count) {
    NSMutableDictionary <NSString *, A00LoadInfoWrapper *> *wrapperMap = [NSMutableDictionary dictionary];
    for (unsigned int i = 0; i < count; i++) {
        const struct mach_header *mhdr = mhdrList[i];
        NSArray <A00LoadInfo *> *infos = getNoLazyArray(mhdr);
        
        LMAllLoadNumber += infos.count;
        
        for (A00LoadInfo *info in infos) {
            A00LoadInfoWrapper *infoWrapper = wrapperMap[info.clsname];
            if (!infoWrapper) {
                Class cls = objc_getClass([info.clsname cStringUsingEncoding:NSUTF8StringEncoding]);
                infoWrapper = [[A00LoadInfoWrapper alloc] initWithClass:cls];
                wrapperMap[info.clsname] = infoWrapper;
            }
            [infoWrapper addLoadInfo:info];
        }
    }
    return wrapperMap;
}

// 使用C++的 __attribute__((constructor))  在main之前收集load方法耗时
// 方法入口，因为该pod排名比较前，且为动态库，所以会优先执行
__attribute__((constructor)) static void LoadMeasure_Initializer(void) {
    NSLog(@"LoadMeasure_Initializer");
    CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();
    unsigned int count = 0;
    const struct mach_header **mhdrList = copyAllSelfDefinedImageHeader(&count);
    NSDictionary <NSString *, A00LoadInfoWrapper *> *groupedWrapperMap = prepareMeasureForMhdrList(mhdrList, count);
    
    for (NSString *clsname in groupedWrapperMap.allKeys) {
        hookAllLoadMethods(groupedWrapperMap[clsname]);
    }
    
    free(mhdrList);
    LMLoadInfoWappers = groupedWrapperMap.allValues;
    
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"Load Measure Initializer Time: %f ms\n", (end - begin) * 1000);
}
