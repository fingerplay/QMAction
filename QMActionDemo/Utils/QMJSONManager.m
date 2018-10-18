//
//  QMJSONManager.m
//  Juanpi_2.0
//
//  Created by lee on 14-2-17.
//  Copyright (c) 2014年 wanwei. All rights reserved.
//

#import "QMJSONManager.h"

@implementation QMJSONManager


+ (id)objectFromJSONString:(NSString *)jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding: NSUTF8StringEncoding];
    return [self objectFromJSONData: jsonData ];
}

+ (id)objectFromJSONData:(NSData *)jsonData
{
    if (!jsonData) {
        return nil;
    }
    
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &error];
    if (error) {
        NSLog(@"%s %@", __FUNCTION__, error);
        return nil;
    }
    
    return result;
}

+ (NSString *)JSONStringFromObject:(id)object
{
    if (!object || ![NSJSONSerialization isValidJSONObject:object]) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *result = [NSJSONSerialization dataWithJSONObject:object options: NSJSONWritingPrettyPrinted error: &error];
    if (error) {
        NSLog(@"%s %@", __FUNCTION__, error);
        return nil;
    }
    
    NSString *resultString = [[NSString alloc] initWithData: result encoding: NSUTF8StringEncoding];
    
    return resultString;
}

@end
