//
//  HDInitializerFrameworkObj.m
//  HDInitializerFramework
//
//  Created by denglibing on 2022/5/27.
//

#import "HDInitializerFrameworkObj.h"

@implementation HDInitializerFrameworkObj

__attribute__((constructor)) void HDLoadFrameworkObj_init(void) {
    NSLog(@"HDInitializerFrameworkObj constructor");
}

__attribute__((constructor)) void HDLoadFrameworkObj_init2(void) {
    NSLog(@"HDInitializerFrameworkObj constructor2");
    sleep(1);
}

@end
