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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [QiCallTrace stop];
        [QiCallTrace save];
        
        [LMLoadInfoWrapper printLoadInfoWappers];
        [A00CppInitMeasure printStaticInitializerTimer];
        [HDLaunchTask printPostMainTime];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
