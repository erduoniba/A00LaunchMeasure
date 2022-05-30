//
//  HookCppInitMeasure.h
//  A00LaunchMeasure
//
//  Created by denglibing on 2022/5/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 https://everettjf.github.io/2017/02/06/a-method-of-hook-static-initializers/
 https://github.com/everettjf/Yolo/blob/master/HookCppInitilizers/hook_cpp_init.mm
 */
@interface A00CppInitMeasure : NSObject

+ (void)printStaticInitializerTimer;

@end

/*
 注意点：
 1、该文件需要添加到主工程中，或者封装成静态库使用；
 2、因为第一个特性，所以无法统计到工程中动态库的耗时数据；
 3、需要将该文件放在编译最前的位置进行统计
 4、TestCode中有常用的 Initializer 方法：
    4.1 析构函数：HDInitializerTest （0.128031 ms）
    4.2 全局变量的初始化需要执行代码：
        结构体赋值：TestCBlock （0.000000 ms）
        需要执行C++类的构造函数：TestClass（0.244021 ms）
        间接导致运行函数：TestMacro（0.795007 ms）
        struct对于C++来说也可以说是一种类：TestRectZero（0.007033 ms）
        const修饰的变量：TestVarVar（0.000000 ms）
 */

NS_ASSUME_NONNULL_END
