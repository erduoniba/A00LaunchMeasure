//
//  HDTaskList.m
//  A00LaunchMeasure
//
//  Created by denglibing on 2022/5/30.
//

#import "HDLaunchTask.h"

#include <os/signpost.h>

os_log_t _log;
os_signpost_id_t _spid;

typedef NSString *HDLaunchTaskTag NS_STRING_ENUM;
HDLaunchTaskTag const HDLaunchTaskTagMainTask = @"mainTasks";
HDLaunchTaskTag const HDLaunchTaskTagAsycTask = @"asycTasks";
HDLaunchTaskTag const HDLaunchTaskTagAfterLaunchMainTask = @"afterLaunchMainTasks";
HDLaunchTaskTag const HDLaunchTaskTagAfterLaunchAsycTask = @"afterLaunchAsycTasks";

typedef struct {
    NSString *const blank;
    NSString *const CDPServer;
    NSString *const countdown;
    NSString *const infoBox;
    NSString *const shop;
    NSString *const more;
    NSString *const CDPSdk;
    NSString *const notice;
    NSString *const recommend;
}O2OPGoodsDetailBlockId;

@interface HDLaunchTask ()

@property (nonatomic, copy) NSMutableArray <id<HDLaunchTaskProtocol>> *mainTasks;
@property (nonatomic, copy) NSMutableArray <id<HDLaunchTaskProtocol>> *asycTasks;
@property (nonatomic, copy) NSMutableArray <id<HDLaunchTaskProtocol>> *afterLaunchMainTasks;
@property (nonatomic, copy) NSMutableArray <id<HDLaunchTaskProtocol>> *afterLaunchAsycTasks;

@property (nonatomic, copy) NSMutableArray <NSDictionary *>*launchTimes;

// 是否已经执行启动任务，如果已经执行，后面的任务不再执行
@property (nonatomic, assign) BOOL haveLaunched;
@property (nonatomic, assign) CGFloat mainTaskTime;

@end

@implementation HDLaunchTask {
    dispatch_queue_t _async_queue;
    dispatch_queue_t _async_queue_after_launch;
}

+ (instancetype)sharedManager {
    static HDLaunchTask *o;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        o = [[HDLaunchTask alloc] init];
    });
    return o;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _async_queue = dispatch_queue_create("com.harry.asynctask", DISPATCH_QUEUE_SERIAL);
        _async_queue_after_launch = dispatch_queue_create("com.harry.asynctaskafterlaunch", DISPATCH_QUEUE_SERIAL);
        _mainTasks = [@[] mutableCopy];
        _asycTasks = [@[] mutableCopy];
        _afterLaunchMainTasks = [@[] mutableCopy];
        _afterLaunchAsycTasks = [@[] mutableCopy];
        _launchTimes = [@[] mutableCopy];
        _haveLaunched = NO;
        _mainTaskTime = 0;
        
        
        if (@available(iOS 12.0, *)) {
            _log = os_log_create("com.harry.taskmamager", "launchTask");
            _spid = os_signpost_id_generate(_log);
        }
    }
    return self;
}

+ (void)addMainTask:(id<HDLaunchTaskProtocol>)task {
    if (HDLaunchTask.sharedManager.haveLaunched) {
        NSAssert(0, @"启动任务已经执行，再次添加将无效");
        return;
    }
    if (task && ![HDLaunchTask.sharedManager.mainTasks containsObject:task]) {
        [HDLaunchTask.sharedManager.mainTasks addObject:task];
    }
}

+ (void)addAsycTask:(id<HDLaunchTaskProtocol>)task {
    if (HDLaunchTask.sharedManager.haveLaunched) {
        NSAssert(0, @"启动任务已经执行，再次添加将无效");
        return;
    }
    if (task && ![HDLaunchTask.sharedManager.asycTasks containsObject:task]) {
        [HDLaunchTask.sharedManager.asycTasks addObject:task];
    }
}

+ (void)addMainTaskAfterLaunch:(id<HDLaunchTaskProtocol>)task {
    if (HDLaunchTask.sharedManager.haveLaunched) {
        NSAssert(0, @"启动任务已经执行，再次添加将无效");
        return;
    }
    if (task && ![HDLaunchTask.sharedManager.afterLaunchMainTasks containsObject:task]) {
        [HDLaunchTask.sharedManager.afterLaunchMainTasks addObject:task];
    }
}

+ (void)addAsycTaskAfterLaunch:(id<HDLaunchTaskProtocol>)task {
    if (HDLaunchTask.sharedManager.haveLaunched) {
        NSAssert(0, @"启动任务已经执行，再次添加将无效");
        return;
    }
    if (task && ![HDLaunchTask.sharedManager.afterLaunchAsycTasks containsObject:task]) {
        [HDLaunchTask.sharedManager.afterLaunchAsycTasks addObject:task];
    }
}

+ (void)run:(UIApplication *)application options:(NSDictionary *)launchOptions {
    if (NSThread.currentThread == NSThread.mainThread) {
        [self run:application options:launchOptions tasks:HDLaunchTask.sharedManager.mainTasks tag:HDLaunchTaskTagMainTask];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self run:application options:launchOptions tasks:HDLaunchTask.sharedManager.mainTasks tag:HDLaunchTaskTagMainTask];
        });
    }
    
    dispatch_async(HDLaunchTask.sharedManager->_async_queue, ^{
        [self run:application options:launchOptions tasks:HDLaunchTask.sharedManager.asycTasks tag:HDLaunchTaskTagAsycTask];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self run:application options:launchOptions tasks:HDLaunchTask.sharedManager.afterLaunchMainTasks tag:HDLaunchTaskTagAfterLaunchMainTask];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), HDLaunchTask.sharedManager->_async_queue_after_launch, ^{
        [self run:application options:launchOptions tasks:HDLaunchTask.sharedManager.afterLaunchAsycTasks tag:HDLaunchTaskTagAfterLaunchAsycTask];
    });
    
    HDLaunchTask.sharedManager.haveLaunched = YES;
}

+ (void)run:(UIApplication *)application options:(NSDictionary *)launchOptions tasks:(NSMutableArray <id<HDLaunchTaskProtocol>>*)tasks tag:(HDLaunchTaskTag)tag {
    for (id<HDLaunchTaskProtocol> task in tasks) {
#ifdef DEBUG
        CFTimeInterval begin = CACurrentMediaTime();
#endif
        [self signposeIntervalBegin:YES tag:tag task:task];
        [task run:application options:launchOptions];
        [self signposeIntervalBegin:NO tag:tag task:task];
#ifdef DEBUG
        CFTimeInterval end = CACurrentMediaTime();
        NSString *key = [NSString stringWithFormat:@"%@-%@", tag, NSStringFromClass(task.class)];
        [HDLaunchTask.sharedManager.launchTimes addObject:@{
            @"clsname" : key,
            @"duration" : @((end - begin))
        }];
        if ([tag isEqualToString:@"mainTasks"]) {
            HDLaunchTask.sharedManager.mainTaskTime += (end - begin);
        }
#endif
    }
}

+ (void)signposeIntervalBegin:(BOOL)begin tag:(HDLaunchTaskTag)tag task:(id<HDLaunchTaskProtocol>)task {
    if (@available(iOS 12.0, *)) {
        if (begin) {
            if (tag == HDLaunchTaskTagMainTask) {
                os_signpost_interval_begin(_log, _spid, "mainTask", "%s", NSStringFromClass(task.class).UTF8String);
            }
            else if (tag == HDLaunchTaskTagAsycTask) {
                os_signpost_interval_begin(_log, _spid, "asycTask", "%s", NSStringFromClass(task.class).UTF8String);
            }
            else if (tag == HDLaunchTaskTagAfterLaunchMainTask) {
                os_signpost_interval_begin(_log, _spid, "afterLaunchMainTask", "%s", NSStringFromClass(task.class).UTF8String);
            }
            else if (tag == HDLaunchTaskTagAfterLaunchAsycTask) {
                os_signpost_interval_begin(_log, _spid, "afterLaunchAsycTask", "%s", NSStringFromClass(task.class).UTF8String);
            }
        }
        else {
            if (tag == HDLaunchTaskTagMainTask) {
                os_signpost_interval_end(_log, _spid, "mainTask", "%s", NSStringFromClass(task.class).UTF8String);
            }
            else if (tag == HDLaunchTaskTagAsycTask) {
                os_signpost_interval_end(_log, _spid, "asycTask", "%s", NSStringFromClass(task.class).UTF8String);
            }
            else if (tag == HDLaunchTaskTagAfterLaunchMainTask) {
                os_signpost_interval_end(_log, _spid, "afterLaunchMainTask", "%s", NSStringFromClass(task.class).UTF8String);
            }
            else if (tag == HDLaunchTaskTagAfterLaunchAsycTask) {
                os_signpost_interval_end(_log, _spid, "afterLaunchAsycTask", "%s", NSStringFromClass(task.class).UTF8String);
            }
        }
    }
}

+(void)printPostMainTime {
#ifdef DEBUG
    printf("\n\t\t\t\t\t\t\tTotal post main time: %f ms", HDLaunchTask.sharedManager.mainTaskTime * 1000);
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO];
    [HDLaunchTask.sharedManager.launchTimes sortUsingDescriptors:@[descriptor]];
    for (NSDictionary *times in HDLaunchTask.sharedManager.launchTimes) {
        printf("\n%40s load time: %f ms", [times[@"clsname"] cStringUsingEncoding:NSUTF8StringEncoding], [times[@"duration"] floatValue] * 1000);
    }
    printf("\n");
#endif
}

@end
