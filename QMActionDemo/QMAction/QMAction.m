//
//  QMAction.m
//  juanpi3
//
//  Created by 罗谨 on 15/7/16.
//  Copyright (c) 2015年 罗谨. All rights reserved.
//

#import "QMAction.h"
#import "QMPushAction.h"
#import "QMCustomAction.h"
#import "NSArray+safe.h"
#import "QMRuntimeHelper.h"
#import "QMJSONManager.h"
#import "NSString+QMHelper.h"
#import "QMActionManager.h"


@implementation QMAction

+ (instancetype)actionWithType:(NSInteger)type module:(NSString *)module content:(NSString *)content {
    return [[self class] actionWithType:type module:module content:content jumpController:nil];
}

+ (instancetype)actionWithType:(NSInteger)type module:(NSString *)module content:(NSString *)content jumpController:(UIViewController *)jumpControl{
    
    Class subClass = [[QMActionManager sharedManager].config actionSubClassForType:type module:module];
    QMAction *action = [[subClass alloc] init];
    action.type = type;
    action.module = module;
    action.jumpController = jumpControl;
    
    //只有type=1情况下，不对从url拿到content字段进行decode，但是对于动态替换的参数会在webVC再解码一次
    content = [content stringByRemovingPercentEncoding];
    action.content = content;
    
    return action;
}


+ (instancetype)actionWithType:(NSInteger)type module:(NSString *)module contentDict:(NSDictionary *)contentDict jumpController:(UIViewController *)jumpControl {
    Class subClass = [[QMActionManager sharedManager].config actionSubClassForType:type module:module];
    QMAction *action = [[subClass alloc] init];
    action.type = type;
    action.contentDict = [contentDict mutableCopy];
    action.jumpController = jumpControl;
    action.module = module;
    return action;
}

+ (instancetype)actionFromUrl:(NSString *)jump_url jumpController:(UIViewController *)jumpController {
    NSString *type = nil;
    NSString *content = nil;
    NSString *source = nil;
    NSDictionary *loginParam = nil;
    NSString *succUrl = nil;
    NSString *failUrl = nil;
    NSString *transitionStyle = nil;
    QMAction *action = nil;
    
    //去除url首尾的空格
    if ([jump_url isKindOfClass:[NSString class]]) {
        jump_url = [jump_url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        jump_url = [jump_url stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    }
    
    NSURL *url = [NSURL URLWithString:jump_url];
    
    if ([url.scheme isEqualToString:ACTION_SCHEME]) {
        
//        NSArray *array = [string componentsSeparatedByString:@"&"];
        NSArray *array = [url.query componentsSeparatedByString:@"&"];
        for (NSInteger i=0; i<array.count; i++) {
            NSString *component = [array safeObjectAtIndex:i];
            NSArray *array3 = [component componentsSeparatedByString:@"="];
            if (array3.count>1) {
                NSString *key = [array3 safeObjectAtIndex:0];
                NSString *value = [array3 safeObjectAtIndex:1];
                if ([key isEqualToString:ACTION_PARAM_TYPE]) {
                    type = value;
                }else if ([key isEqualToString:ACTION_PARAM_CONTENT]) {
                    content = value;
                }else if ([key isEqualToString:ACTION_PARAM_LOGINPARAM]) {
                    value = [value stringByRemovingPercentEncoding];
                    NSDictionary *dict = [QMJSONManager objectFromJSONString:value];
                    loginParam = [NSMutableDictionary dictionaryWithDictionary:dict];
                    
                } else if ([key isEqualToString:ACTION_PARAM_SOURCE]) {
                    source = value;
                }else if ([key isEqualToString:ACTION_PARAM_SUCCURL]) {
                    succUrl = value;
                }else if ([key isEqualToString:ACTION_PARAM_FAILURL]) {
                    failUrl = value;
                }else if ([key isEqualToString:ACTION_PARAM_TRANSITIONSTYLE]){
                    transitionStyle = value;
                }
            }
        }
        
        action = [QMAction actionWithType:type.integerValue module:url.host content:content jumpController:jumpController];
        action.url = jump_url;
        if ([action isKindOfClass:[QMPushAction class]]) {
            ((QMPushAction*)action).transitionStyle = @(transitionStyle.integerValue);
        }
        action.loginParam = loginParam;
        if (source.length > 0) {
            action.source = source;
        }
        action.succUrl = [succUrl stringByRemovingPercentEncoding];
        action.failUrl = [failUrl stringByRemovingPercentEncoding];
        
    }

    return action;
}


- (void)setValuesForObject:(id)object {
    if (self.userInfo && object) {
        for (id key in self.userInfo.allKeys) {
            if (![key isKindOfClass:[NSString class]]) {
                NSCAssert(NO, @"key:%@ 不是字符串",key);
                continue;
            }
            if (![QMRuntimeHelper isClass:[object class] hasProperty:key]) {
                NSCAssert(NO, @"key:%@ 不存在 ",key);
                continue;
            }

            id value = [self.userInfo objectForKey:key];
            NSError *error = nil;
            if (![object validateValue:&value forKey:key error:&error]) {
                NSCAssert(NO, @"value:%@ 类型错误,key:%@",value,key);
                continue;
            } else {
                [object setValue:value forKey:key];
            }
        }
    }
}


- (NSMutableDictionary *)contentDict {
    if (!_contentDict) {
        if (self.content && self.content.length) {
            NSDictionary *dict = [QMJSONManager objectFromJSONString:self.content];
            _contentDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        }
    }
    return _contentDict;
}

@end
