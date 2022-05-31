//
//  HDLaunchTaskManager.m
//  A00LaunchMeasure_Example
//
//  Created by denglibing on 2022/5/31.
//  Copyright © 2022 denglibing5. All rights reserved.
//

#import "HDLaunchTaskManager.h"

#import "HDLaunchDemo.h"

#define TaskObj(TaskName) NSClassFromString(TaskName).new

@implementation HDLaunchTaskManager

+ (void)run:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [HDLaunchTask addMainTask:HDLaunchDemo.new];
    [HDLaunchTask addMainTask:TaskObj(@"TTObserveTask")];
    [HDLaunchTask addMainTask:TaskObj(@"TTAppleTask")];
    [HDLaunchTask addMainTask:TaskObj(@"TTPearTask")];
    
    [HDLaunchTask addAsycTask:TaskObj(@"TTLoginTask")];
    [HDLaunchTask addAsycTask:TaskObj(@"TTPrepareTask")];
    [HDLaunchTask addAsycTask:TaskObj(@"TTPrefetchTask")];
    [HDLaunchTask addAsycTask:TaskObj(@"TTProcessTask")];
    [HDLaunchTask addAsycTask:TaskObj(@"TTCompletionTask")];
    [HDLaunchTask addAsycTask:TaskObj(@"TTDoneTask")];
    
    [HDLaunchTask addMainTaskAfterLaunch:TaskObj(@"TTDownloadTask")];
    
    [HDLaunchTask addAsycTaskAfterLaunch:TaskObj(@"TTRenderTask")];
    
    [HDLaunchTask run:application options:launchOptions];
}

@end
