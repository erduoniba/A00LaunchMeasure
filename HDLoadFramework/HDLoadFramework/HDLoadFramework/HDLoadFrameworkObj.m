//
//  HDLoadFrameworkObj.m
//  HDLoadFramework
//
//  Created by denglibing on 2022/5/24.
//

#import "HDLoadFrameworkObj.h"

@implementation HDLoadFrameworkObj

+ (void)load {
    NSLog(@"HDLoadFrameworkObj load");
    sleep(1);
}

+ (void)ddd {
    NSLog(@"ddd0");
}

__attribute__((constructor)) void HDLoadFrameworkObj_init(void) {
    NSLog(@"HDLoadFrameworkObj constructor");
    sleep(2);
}

__attribute__((constructor)) void HDLoadFrameworkObj_init2(void) {
    NSLog(@"HDLoadFrameworkObj constructor2");
    sleep(1);
}

@end


@implementation HDLoadFrameworkObj (HDLoad0)
+ (void)load {
    NSLog(@"HDLoadFrameworkObj+HDLoad0 load");
    sleep(2);
}
+ (void)ddd2 {
    NSLog(@"ddd2");
}
+ (void)ddd3 {
    NSLog(@"ddd3");
}
@end
