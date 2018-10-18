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

    return NO;
}

- (void)performAction:(QMAction *)action afterLogin:(void (^)())completion{

}

@end
