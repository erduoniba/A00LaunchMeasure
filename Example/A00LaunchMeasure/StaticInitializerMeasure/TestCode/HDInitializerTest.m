//
//  HDInitializerTest.m
//  A00LaunchMeasure_Example
//
//  Created by denglibing on 2022/5/30.
//  Copyright © 2022 denglibing5. All rights reserved.
//

#import "HDInitializerTest.h"

@implementation HDInitializerTest

__attribute__((constructor)) static void HDInitializerTest_Initializer(void) {
    sleep(1);
    NSLog(@"HDInitializerTest_Initializer");
}

@end


@implementation HDInitializerTest (Test)

__attribute__((constructor)) static void HDInitializerTest_Initializer2(void) {
    NSLog(@"HDInitializerTest+Test_Initializer");
}

@end
