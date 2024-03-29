//
//  HDViewController.m
//  A00LaunchMeasure
//
//  Created by denglibing5 on 05/23/2022.
//  Copyright (c) 2022 denglibing5. All rights reserved.
//

#import "HDViewController.h"

#import <A00LaunchMeasure/A00LoadMeasure.h>
#import <A00LaunchMeasure/HDLaunchTask.h>
#import <A00LaunchMeasure/QiCallTrace.h>
#import "A00CppInitMeasure.h"

@interface HDViewController ()

@end

@implementation HDViewController

+ (void)load {
    NSLog(@"HDViewController load");
    usleep(1000 * 50);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self test1_1];
    [self test2_1];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [QiCallTrace stop];
        [QiCallTrace save];
        
        [LMLoadInfoWrapper printLoadInfoWappers];
        [A00CppInitMeasure printStaticInitializerTimer];
        [HDLaunchTask printPostMainTime];
    });
}

- (void)test1_1 {
    usleep(100 * 1000);
    [self test1_2];
    [self test1_3];
}

- (void)test1_2 {
    usleep(200 * 1000);
}

- (void)test1_3 {
    usleep(300 * 1000);
}

- (void)test2_1 {
    usleep(100 * 1000);
    [self test2_2];
    [self test2_3];
}

- (void)test2_2 {
    usleep(200 * 1000);
}

- (void)test2_3 {
    usleep(300 * 1000);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
