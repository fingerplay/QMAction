//
//  QMAction+Login.m
//  juanpi3
//
//  Created by 罗谨 on 2017/8/9.
//  Copyright © 2017年 罗谨. All rights reserved.
//

#import "QMActionConfig.h"
#import "QMJSONManager.h"

@implementation QMActionConfig


- (Class)actionSubClassForType:(QMActionType)type {
    
    return [QMPushAction class];
}


- (BOOL)isNeedLogin:(QMAction*)action {
    
    return NO;
}

- (BOOL)isNeedRecordToDB:(QMAction*)action {

    return NO;
}


@end
