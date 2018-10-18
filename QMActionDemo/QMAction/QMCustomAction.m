//
//  QMCustomAction.m
//  juanpi3
//
//  Created by 罗谨 on 15/7/17.
//  Copyright (c) 2015年 罗谨. All rights reserved.
//

#import "QMCustomAction.h"

@implementation QMCustomAction

//重载父类的该方法，如果调用者使用[QMCustomAction actionWithType ...]来获取action实例，则无视type的值，统一返回QMCustomAction的实例
+ (Class)actionSubClassForType:(QMActionType)type {
    return [self class];
}

+ (instancetype)actionFromUrl:(NSString *)jump_url {
    NSCAssert(NO, @"不要在子类调用该方法!!");
    return nil;
}

@end
