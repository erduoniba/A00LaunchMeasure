#
# Be sure to run `pod lib lint A00LaunchMeasure.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'A00LaunchMeasure'
  s.version          = '0.1.4'
  s.summary          = '统计启动时刻的方法耗时，方便在做启动优化的时候定位排查问题'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                      0.1.1: 添加启动时刻的load方法和initializer方法耗时统计
                      0.1.2: 添加简单的启动服务管理类
                      0.1.3: 添加AfterMeasure用于测量启动后的函数耗时
                       DESC

  s.homepage         = 'https://github.com/erduoniba/A00LaunchMeasure'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'denglibing' => 'denglibing@hd.com' }
  s.source           = { :git => 'https://github.com/erduoniba/A00LaunchMeasure.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  
  # 设置为动态库
  s.static_framework = false
  
  s.subspec 'LoadMeasure' do |loadMeasure|
    loadMeasure.source_files = 'A00LaunchMeasure/Classes/LoadMeasure/*.{h,m}'
  end
  
  s.subspec 'TaskList' do |taskList|
    taskList.source_files = 'A00LaunchMeasure/Classes/TaskList/*.{h,m}'
  end
  
  s.subspec 'AfterMeasure' do |afterMeasure|
    afterMeasure.source_files = 'A00LaunchMeasure/Classes/AfterMeasure/**/*.{h,m,c}'
  end
  
  # s.resource_bundles = {
  #   'A00LaunchMeasure' => ['A00LaunchMeasure/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
