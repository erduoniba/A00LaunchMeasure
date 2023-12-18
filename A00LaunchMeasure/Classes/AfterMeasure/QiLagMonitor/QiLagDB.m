//
//  QiLagDB.m
//  Qi_ObjcMsgHook
//
//  Created by liusiqi on 2019/11/20.
//  Copyright © 2019 QiShare. All rights reserved.
//

#import "QiLagDB.h"

#import "QiCallTraceTimeCostModel.h"

#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface QiLagDB()

@property (nonatomic, copy) NSString *clsCallDBPath;
//@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation QiLagDB

+ (QiLagDB *)shareInstance {
    static QiLagDB *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QiLagDB alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _clsCallDBPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"clsCall.sqlite"];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:_clsCallDBPath] == NO) {
//            FMDatabase *db = [FMDatabase databaseWithPath:_clsCallDBPath];
//            if ([db open]) {
//                /* clsCall 表记录方法读取频次的表
//                 cid: 主id
//                 fid: 父id 暂时不用
//                 cls: 类名
//                 mtd: 方法名
//                 path: 完整路径标识
//                 timecost: 方法消耗时长
//                 calldepth: 层级
//                 frequency: 调用次数
//                 lastcall: 是否是最后一个 call
//                 */
//                NSString *createSql = @"create table clscall (cid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, fid integer, cls text, mtd text, path text, timecost double, calldepth integer, frequency integer, lastcall integer)";
//                [db executeUpdate:createSql];
//
//                /* stack 表记录
//                 sid: id
//                 stackcontent: 堆栈内容
//                 insertdate: 日期
//                 */
//                NSString *createStackSql = @"create table stack (sid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, stackcontent text,isstuck integer, insertdate double)";
//                [db executeUpdate:createStackSql];
//            }
//        }
//        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:_clsCallDBPath];
    }
    return self;
}

#pragma mark - ClsCall方法调用频次
//添加记录
- (void)addWithClsCallModel:(QiCallTraceTimeCostModel *)model {
    if ([model.methodName isEqualToString:@"clsCallInsertToViewWillAppear"] || [model.methodName isEqualToString:@"clsCallInsertToViewWillDisappear"]) {
        return;
    }
//    [self.dbQueue inDatabase:^(FMDatabase *db){
//        if ([db open]) {
//            //添加白名单
//            FMResultSet *rsl = [db executeQuery:@"select cid,frequency from clscall where path = ?", model.path];
//            if ([rsl next]) {
//                //有相同路径就更新路径访问频率
//                int fq = [rsl intForColumn:@"frequency"] + 1;
//                int cid = [rsl intForColumn:@"cid"];
//                [db executeUpdate:@"update clscall set frequency = ? where cid = ?", @(fq), @(cid)];
//            } else {
//                //没有就添加一条记录
//                NSNumber *lastCall = @0;
//                if (model.lastCall) {
//                    lastCall = @1;
//                }
//                [db executeUpdate:@"insert into clscall (cls, mtd, path, timecost, calldepth, frequency, lastcall) values (?, ?, ?, ?, ?, ?, ?)", model.className, model.methodName, model.path, @(model.timeCost), @(model.callDepth), @1, lastCall];
//            }
//            [db close];
//        }
//    }];
}

@end
