//
//  TestClass.m
//  ModFuncInitApp
//
//  Created by everettjf on 2016/12/6.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "TestClass.h"

class FooObject{
public:
    FooObject(NSString *str){
        // do somthing
        NSLog(@"in fooobject %@", str);
    }
    
};

static FooObject globalObj = FooObject(@"1");
FooObject globalObj2 = FooObject(@"2");
