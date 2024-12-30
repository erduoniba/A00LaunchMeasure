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
@interface A00LoadInfoWrapper : NSObject
+(void)printLoadInfoWappers;
@end

/*
 一种 hook load 的方法
 
 注意点：
 1、该组件需要以动态库的方式被集成，如果是静态库会有问题
 
 结论:
 1、可以收集到主工程所有的load方法并统计耗时；
 2、可以收集到静态库的所有load方法并统计耗时，静态库的分类需要在主工程的Other Linker Flags添加 -ObjC
 3、可以收集动态库所有load方法并统计耗时
 
 */

/*
 MachO中扩展字段说明
 sectname section名称，部分列举：
  1. __got:存储引用符号的实际地址，类似于动态符号表，存储了`__nl_symbol_ptr`相关函数指针。
  2. __la_symbol_ptr:lazy symbol pointers。懒加载的函数指针地址（C代码实现的函数对应实现的地址）。和__stubs和stub_helper配合使用。具体原理暂留。
  3. __mod_init_func:模块初始化的方法。（可以检测收集C++初始化方法，实现参考A00CppInitMeasure）
  4. __const:存储constant常量的数据。比如使用extern导出的const修饰的常量。
  5. __cfstring:使用Core Foundation字符串
  6. __objc_classlist:objc类列表,保存类信息，映射了__objc_data的地址
  7. __objc_nlclslist:Objective-C 的 +load 函数列表，比 __mod_init_func 更早执行。
  8. __objc_catlist: categories
  9. __objc_nlcatlist:Objective-C 的categories的 +load函数列表。
  10. __objc_protolist:objc协议列表
  11. __objc_imageinfo:objc镜像信息
  12. __objc_const:objc常量。保存objc_classdata结构体数据。用于映射类相关数据的地址，比如类名，方法名等。
  13. __objc_selrefs:引用到的objc方法
  14. __objc_protorefs:引用到的objc协议
  15. __objc_classrefs:引用到的objc类
  16. __objc_superrefs:objc超类引用
  17. __objc_ivar:objc ivar指针,存储属性。
  18. __objc_data:objc的数据。用于保存类需要的数据。最主要的内容是映射__objc_const地址，用于找到类的相关数据。
  19. __data:暂时没理解，从日志看存放了协议和一些固定了地址（已经初始化）的静态量。
  20. __bss:存储未初始化的静态量。比如：`static NSThread *_networkRequestThread = nil;`其中这里面的size表示应用运行占用的内存，不是实际的占用空间。所以计算大小的时候应该去掉这部分数据。
  21. __common:存储导出的全局的数据。类似于static，但是没有用static修饰。比如KSCrash里面`NSDictionary* g_registerOrders;`, g_registerOrders就存储在__common里面
 */

NS_ASSUME_NONNULL_END
