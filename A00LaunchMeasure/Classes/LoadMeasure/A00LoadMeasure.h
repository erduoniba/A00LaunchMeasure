//
//  A00LoadMeasure.h
//  A00LaunchMeasure
//
//  Created by denglibing on 2022/5/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// https://github.com/tripleCC/Laboratory
// https://triplecc.github.io/2019/05/27/%E8%AE%A1%E7%AE%97load%E8%80%97%E6%97%B6/
@interface LMLoadInfo : NSObject
@property (copy, nonatomic, readonly) NSString *clsname;
@property (copy, nonatomic, readonly) NSString *catname;
@property (assign, nonatomic, readonly) CFAbsoluteTime start;
@property (assign, nonatomic, readonly) CFAbsoluteTime end;
@property (assign, nonatomic, readonly) CFAbsoluteTime duration;
@end

@interface LMLoadInfoWrapper : NSObject
@property (assign, nonatomic, readonly) Class cls;
@property (copy, nonatomic, readonly) NSArray <LMLoadInfo *> *infos;
+(void)printLoadInfoWappers;
@end

extern NSArray <LMLoadInfoWrapper *> *LMLoadInfoWappers;

/*
 注意点：
 1、该组件需要以动态库的方式被集成，如果是静态库会有问题
 
 结论:
 1、可以收集到主工程所有的load方法并统计耗时；
 2、可以收集到静态库的所有load方法并统计耗时，静态库的分类需要在主工程的Other Linker Flags添加 -ObjC
 3、可以收集动态库所以load方法并统计耗时
 
 */

NS_ASSUME_NONNULL_END
