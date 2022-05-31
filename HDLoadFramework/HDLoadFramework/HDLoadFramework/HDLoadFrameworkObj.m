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
    usleep(1000 * 10);
}

+ (void)ddd {
    NSLog(@"ddd0");
}

__attribute__((constructor)) void HDLoadFrameworkObj_init(void) {
    NSLog(@"HDLoadFrameworkObj constructor");
    usleep(1000 * 20);
}

__attribute__((constructor)) void HDLoadFrameworkObj_init2(void) {
    NSLog(@"HDLoadFrameworkObj constructor2");
    usleep(1000 * 100);
}

@end


@implementation HDLoadFrameworkObj (HDLoad0)
+ (void)load {
    NSLog(@"HDLoadFrameworkObj+HDLoad0 load");
    usleep(1000 * 200);
}
+ (void)ddd2 {
    NSLog(@"ddd2");
}
+ (void)ddd3 {
    NSLog(@"ddd3");
}
@end
