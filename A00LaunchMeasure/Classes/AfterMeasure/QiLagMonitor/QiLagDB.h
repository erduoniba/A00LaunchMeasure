//
//  QiLagDB.h
//  Qi_ObjcMsgHook
//
//  Created by liusiqi on 2019/11/20.
//  Copyright © 2019 QiShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QiCallTraceTimeCostModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QiLagDB : NSObject

+ (QiLagDB *)shareInstance;
/*------------ClsCall方法调用频次-------------*/
//添加记录s
- (void)addWithClsCallModel:(QiCallTraceTimeCostModel *)model;

@end

NS_ASSUME_NONNULL_END
