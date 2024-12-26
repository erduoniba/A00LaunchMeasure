# A00LaunchMeasure

[![CI Status](https://img.shields.io/travis/denglibing5/A00LaunchMeasure.svg?style=flat)](https://travis-ci.org/denglibing5/A00LaunchMeasure)
[![Version](https://img.shields.io/cocoapods/v/A00LaunchMeasure.svg?style=flat)](https://cocoapods.org/pods/A00LaunchMeasure)
[![License](https://img.shields.io/cocoapods/l/A00LaunchMeasure.svg?style=flat)](https://cocoapods.org/pods/A00LaunchMeasure)
[![Platform](https://img.shields.io/cocoapods/p/A00LaunchMeasure.svg?style=flat)](https://cocoapods.org/pods/A00LaunchMeasure)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

A00LaunchMeasure is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'A00LaunchMeasure'
```

使用 `IS_SOURCE=1 pod install` 进行安装，最终以源码依赖。（在App中可能被强制改成静态库，导致统计无效）
使用 `pod install` 进行安装，最终以动态库二进制依赖。（推荐）
结合 https://github.com/erduoniba/A00CppInitMeasure 一起使用

## Author

denglibing, denglibing@gmail.com

## License

A00LaunchMeasure is available under the MIT license. See the LICENSE file for more info.





## 1、比较体系化的文章（指南）

系统的整理了启动阶段、原理、方案、工具等点

[过去一段时间的iOS启动优化文章目录](https://everettjf.github.io/2018/12/12/ios-app-launch-perf-coll/#pre-main-阶段)

[iOS应用启动性能优化资料](https://everettjf.github.io/2018/08/06/ios-launch-performance-collection/)

## 2、各个大公司启动优化文章（增长见识及学习新的方案）

从背景到问题发现，优化过程，然后到原理，再到如何预防监控说明，比较系统的讲述了整个过程。其中也包含了比较多新知识（例如后台激活、启动后任务管理TTI、火焰图）。细节倒不是很详细

[快手 iOS 启动优化实践](https://mp.weixin.qq.com/s/ph7kFRKYWP1bqbNtTK4z3Q)

抖音品质建设 - iOS启动优化《原理篇》

[抖音品质建设 - iOS启动优化《原理篇》 - 掘金](https://juejin.cn/post/6887741815529832456)

抖音品质建设 - iOS启动优化《实战篇》

[抖音品质建设 - iOS启动优化《实战篇》 - 掘金](https://juejin.cn/post/6921508850684133390)

## 3、二进制重排相关文章：（技术细节）

从动态库改静态库、二进制重排两个方向来优化

[我是如何让微博绿洲的启动速度提升30%的 - 掘金](https://juejin.cn/post/6844904143111323661)

详细的介绍二进制重排方案

[iOS App启动优化（一）：检测启动时间 - 掘金](https://juejin.cn/post/6844904165773328392)

使用Pods能力来支持二进制重排，同时支持Pods中其他动态库

[懒人版二进制重排 - 掘金](https://juejin.cn/post/6844904192193085448)

## 4、Load方法耗时统计文章（技术细节）

**计算 +load 方法的耗时，靠谱，已经在使用：**

详细的介绍如何检测load方法的耗时，技术方案全面靠谱，也有方案的选型细节和原因，非常好

兼容category的load方法，使用runtime（`method_exchangeImplementations`）交换load实现然后进行耗时埋点

https://triplecc.github.io/2019/05/27/计算load耗时/

https://github.com/tripleCC/Laboratory/tree/master/HookLoadMethods/A4LoadMeasure

## 5、自动检测启动时刻OC方法耗时（工具使用）

**可视化工具，检测post-main的耗时，自动生成火焰图**

[Messier - 简单易用的Objective-C方法跟踪工具](https://everettjf.github.io/2019/05/06/messier/#背景)

目前不支持iOS15的机器，崩溃的原因应该和 fishhook 差不多。

fishhook解决方案：https://github.com/facebook/fishhook/pull/87/files

[trace.json](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c1b40e30-7c17-4e96-9f37-94ffb981f14a/trace.json)

下载上面的 trace.json 文件，拖入到 chrome://tracing/ 可以看到效果

![img](https://spotless-dragon-2b6.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Ff7d542c3-161e-48e9-b2ff-edcabf91e6a7%2FUntitled.png?table=block&id=1da5b88f-6227-4a1d-a1a3-e6b482eebd65&spaceId=11661b9d-e796-4b15-be83-2c4bcd14fbdf&width=2000&userId=&cache=v2)



```shell
Total load time: 596.920967 ms
            HDLoadFrameworkObj(HDLoad00) load time: 301.328063 ms
             HDLoadFrameworkObj(HDLoad0) load time: 201.607943 ms
                        HDViewController load time: 51.537037 ms
                        messier_injector load time: 14.590979 ms
                HDViewController(HDLoad) load time: 11.595964 ms
                      HDLoadFrameworkObj load time: 11.392951 ms
                       A00CppInitMeasure load time: 4.301071 ms
                           HDAppDelegate load time: 0.566959 ms

					Total initializer time: 47.639012 ms
_GLOBAL__sub_I_TestStaticClassMemberMutex.cpp : 0.042081 ms
           HDInitializerTest_Initializer : 41.468979 ms
          HDInitializerTest_Initializer2 : 0.349045 ms
          _GLOBAL__sub_I_TestRectZero.mm : 0.023961 ms
            _GLOBAL__sub_I_TestVarVar.mm : 0.001907 ms
             _GLOBAL__sub_I_TestMacro.mm : 5.074024 ms
            _GLOBAL__sub_I_TestCBlock.mm : 0.002980 ms
             _GLOBAL__sub_I_TestClass.mm : 0.676036 ms

							Total post main time: 536.512167 ms
                   asycTasks-TTLoginTask load time: 377.533173 ms
                    asycTasks-TTDoneTask load time: 316.752350 ms
       afterLaunchAsycTasks-TTRenderTask load time: 316.671448 ms
              asycTasks-TTCompletionTask load time: 315.872375 ms
                 asycTasks-TTPrepareTask load time: 315.784119 ms
     afterLaunchMainTasks-TTDownloadTask load time: 312.958099 ms
                    mainTasks-TTPearTask load time: 212.643372 ms
                 mainTasks-TTObserveTask load time: 211.551453 ms
                asycTasks-TTPrefetchTask load time: 114.505920 ms
                   mainTasks-TTAppleTask load time: 111.962204 ms
                 asycTasks-TTProcessTask load time: 11.648625 ms
                  mainTasks-HDLaunchDemo load time: 0.355125 ms
```

