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

+ (instancetype)actionWithType:(QMActionType)type content:(NSString *)content {
    return [[self class] actionWithType:type content:content jumpController:nil];
}

+ (instancetype)actionWithType:(QMActionType)type content:(NSString *)content jumpController:(UIViewController *)jumpControl{
    
    Class subClass = [[QMActionManager sharedManager].config actionSubClassForType:type];
    QMAction *action = [[subClass alloc] init];
    action.type = type;
    action.jumpController = jumpControl;
    
    //只有type=1情况下，不对从url拿到content字段进行decode，但是对于动态替换的参数会在webVC再解码一次
    if (type == QMActionTypeDefaultWebVC) {
        action.content = content;
    } else {
        content = [content stringByRemovingPercentEncoding];
//        action.content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        action.content = content;
    }
    
    [action parseContent];
    
    return action;
}


+ (instancetype)actionWithType:(QMActionType)type contentDict:(NSDictionary *)contentDict jumpController:(UIViewController*)jumpControl{
    Class subClass = [[self class] actionSubClassForType:type];
    QMAction *action = [[subClass alloc] init];
    action.type = type;
    action.contentDict = [contentDict mutableCopy];
    action.jumpController = jumpControl;
    
    [action parseContent];
    return action;
}

+ (instancetype)actionFromUrl:(NSString *)jump_url jumpController:(UIViewController *)jumpController {
    NSString *type = nil;
    NSString *content = nil;
    NSString *source = nil;
    NSString *needlogin = nil;
    QMAction *action = nil;
    
    //去除url首尾的空格
    if ([jump_url isKindOfClass:[NSString class]]) {
        jump_url = [jump_url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        jump_url = [jump_url stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    }
    
    if ([jump_url hasPrefix:PreString] || [jump_url hasPrefix:ActionPreString]) {
    
        NSString *string = nil;
        if ([jump_url hasPrefix:PreString]) {
            string = [jump_url substringFromIndex:PreString.length];
        }else if ([jump_url hasPrefix:ActionPreString]){
            string = [jump_url substringFromIndex:ActionPreString.length];
        }
        
        NSArray *array = [string componentsSeparatedByString:@"&"];
        if (array.count>0) {
            //先解析type
            type = [array safeObjectAtIndex:0];
            if (array.count > 1) {
                NSString *subString = [string substringFromIndex:type.length + 1];
                //解析content
                NSRange contentKeyRange = [subString rangeOfString:ContentKey];
                if (contentKeyRange.location != NSNotFound) {
                    NSInteger contentValueStart = contentKeyRange.location + contentKeyRange.length;
                    content = [subString substringWithRange:NSMakeRange(contentValueStart, subString.length - contentValueStart)];
                    subString = [subString substringToIndex:contentValueStart-1];
                }
                //解析除type和content之外的其他字段
                NSArray *array2 = [subString componentsSeparatedByString:@"&"];
                if (array2.count>0) {
                    for (NSInteger i=0; i<array2.count; i++) {
                        NSString *component = [array2 safeObjectAtIndex:i];
                        NSArray *array3 = [component componentsSeparatedByString:@"="];
                        if (array3.count>1) {
                            NSString *key = [array3 safeObjectAtIndex:0];
                            NSString *value = [array3 safeObjectAtIndex:1];
                            if ([key isEqualToString:@"needlogin"]) {
                                needlogin = value;
                            } else if ([key isEqualToString:@"source"]) {
                                source = value;
                            }
                        }
                    }
                }
            }
        }
        
        action = [QMAction actionWithType:type.integerValue content:content jumpController:jumpController];
        action.url = jump_url;
        action.needlogin = needlogin;
        if (source.length > 0) {
            action.source = source;
        }
        
    } else if ([jump_url isHTTPLink]) {
        action = [QMAction actionWithType:QMActionTypeDefaultWebVC content:jump_url jumpController:jumpController];
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


- (void)parseContent {
    //to be override
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
