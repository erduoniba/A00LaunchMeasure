//
//  HDTaskList.h
//  A00LaunchMeasure
//
//  Created by denglibing on 2022/5/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HDLaunchTaskProtocol <NSObject>

- (void)run:(UIApplication *)application options:(NSDictionary *)launchOptions;

@end

/*
 https://everettjf.github.io/2018/08/24/most-simple-task-queue-model/
 https://everettjf.github.io/2018/08/13/os-signpost-tutorial/
 */
@interface HDLaunchTask : NSObject

// 启动主线程就需要初始化的任务（串行队列）
+ (void)addMainTask:(id<HDLaunchTaskProtocol>)task;

// 启动异步线程就需要初始化的任务（串行队列）
+ (void)addAsycTask:(id<HDLaunchTaskProtocol>)task;

// 延迟2秒在主线程执行任务
+ (void)addMainTaskAfterLaunch:(id<HDLaunchTaskProtocol>)task;

// 延迟2秒在异步线程执行任务
+ (void)addAsycTaskAfterLaunch:(id<HDLaunchTaskProtocol>)task;

// 执行启动任务，需要在添加之后主动调用
+ (void)run:(UIApplication *)application options:(NSDictionary *)launchOptions;

//  打印postmain阶段的耗时，在首页的viewDidLoad执行
+(void)printPostMainTime;

@end

NS_ASSUME_NONNULL_END
