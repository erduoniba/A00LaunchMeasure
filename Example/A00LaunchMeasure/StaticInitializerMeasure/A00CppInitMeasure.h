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

/*
 缺陷：无法使用动态库去统计相关数据耗时；https://www.jianshu.com/p/c14987eee107
 
 if ( type == S_MOD_INIT_FUNC_POINTERS ) {
     Initializer* inits = (Initializer*)(sect->addr + fSlide);
     const size_t count = sect->size / sizeof(uintptr_t);
     
     for (size_t j=0; j < count; ++j) {
         Initializer func = inits[j];
         // <rdar://problem/8543820&9228031> verify initializers are in image
         if ( ! this->containsAddress((void*)func) ) {
             dyld::throwf("initializer function %p not in mapped image for %s\n", func, this->getPath());
         }
     
         func(context.argc, context.argv, context.envp, context.apple, &context.programVars);
     }
 }
 
 if ( ! this->containsAddress((void*)func) ) 这里会做一个判断，判断函数地址是否在当前 image 的地址空间中，因为我们是在一个独立的动态库中做函数地址替换，替换后的函数地址都是我们动态库中的，并没有在其他 image 中，所以当其他 image 执行到这个判断时，就抛出了异常。这个问题好像无解，所以我们的 C++ Static Initializers 时间统计稍有不足。
 */

NS_ASSUME_NONNULL_END
