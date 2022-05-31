//
//  HDLaunchDemo.m
//  A00LaunchMeasure_Example
//
//  Created by denglibing on 2022/5/31.
//  Copyright © 2022 denglibing5. All rights reserved.
//

#import "HDLaunchDemo.h"

#define TaskDeclare(TaskName) \
@interface TaskName : NSObject<HDLaunchTaskProtocol> \
@end \
@implementation TaskName \
- (void)run:(UIApplication *)application options:(NSDictionary *)launchOptions { \
NSLog(@"%@ run", NSStringFromClass([self class])); \
usleep(arc4random() % 4 * 1000 * 100 + 10*1000); \
} \
@end

@interface HDLaunchDemo ()

@end

@implementation HDLaunchDemo

- (void)run:(UIApplication *)application options:(NSDictionary *)launchOptions {
    NSLog(@"HDLaunchDemo run");
}

@end


TaskDeclare(TTObserveTask)

TaskDeclare(TTAppleTask)
TaskDeclare(TTBananaTask)
TaskDeclare(TTPearTask)

TaskDeclare(TTLoginTask)
TaskDeclare(TTPrepareTask)
TaskDeclare(TTPrefetchTask)
TaskDeclare(TTProcessTask)
TaskDeclare(TTCompletionTask)
TaskDeclare(TTDoneTask)

TaskDeclare(TTDownloadTask)
TaskDeclare(TTRenderTask)
