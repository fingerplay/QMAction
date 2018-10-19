//
//  QMActionManager+Login.m
//  juanpi3
//
//  Created by 罗谨 on 2017/8/9.
//  Copyright © 2017年 罗谨. All rights reserved.
//

#import "QMActionManager+Login.h"
#import "QMActionConfig.h"


@implementation QMActionManager (Login)

//检查action，如果需要登录的先登录再执行action
- (BOOL)shouldPerformLoginBeforeAction:(QMAction *)action {

    //这里写一些是否需要登录的判断逻辑...
    return NO;
}

- (BOOL)isLoginParamMatchWithParams:(NSDictionary*)params {
    
//..这里获取参数进行比较
//    NSString *userId = [params objectForKey:@"userId"];

    return YES;
}

- (void)performLoginWithAction:(QMAction *)action completion:(void (^)(BOOL))completion{

    //..这里进行登陆操作
}


@end
