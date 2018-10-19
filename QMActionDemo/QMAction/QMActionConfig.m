//
//  QMAction+Login.m
//  juanpi3
//
//  Created by 罗谨 on 2017/8/9.
//  Copyright © 2017年 罗谨. All rights reserved.
//

#import "QMActionConfig.h"

@implementation QMActionConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _classMapCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (Class)actionSubClassForType:(QMActionType)type module:(NSString*)module{
    if ([module isEqualToString:ACTION_MODULE_HOME]) {
        return [QMCustomAction class];
    }
    

    return [QMPushAction class];
}


- (BOOL)isNeedLogin:(QMAction*)action {
    return NO;
}

- (NSString*)cacheMapKeyForAction:(QMAction*)action {
    NSString *key;
    if (action.subtype) {
        key = [NSString stringWithFormat:@"%@_%ld_%ld",action.module,(long)action.type, (long)action.subtype];
    }else{
        key = [NSString stringWithFormat:@"%@_%ld",action.module,(long)action.type];
    }
    
    return key;
}

- (void)registerClass:(Class<QMActionProtocol>)cls forAction:(QMAction *)action {
    if (cls && action) {
        [_classMapCache setObject:cls forKey:[self cacheMapKeyForAction:action]];
    }
}

@end
