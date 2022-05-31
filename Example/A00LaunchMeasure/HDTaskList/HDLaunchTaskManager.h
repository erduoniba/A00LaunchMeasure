//
//  HDLaunchTaskManager.h
//  A00LaunchMeasure_Example
//
//  Created by denglibing on 2022/5/31.
//  Copyright © 2022 denglibing5. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <A00LaunchMeasure/HDLaunchTask.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDLaunchTaskManager : NSObject

+ (void)run:(UIApplication *)application options:(NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END
