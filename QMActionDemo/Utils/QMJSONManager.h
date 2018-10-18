//
//  QMJSONManager.h
//  Juanpi_2.0
//
//  Created by lee on 14-2-17.
//  Copyright (c) 2014年 wanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMJSONManager : NSObject


/**
*  将JSON字符串解析为对象
*
*  @param jsonString JSON String
*
*  @return object
*/
+ (id)objectFromJSONString:(NSString *)jsonString;

/**
 *  将JSON字符串解析为对象
 *
 *  @param jsonData JSON Data
 *
 *  @return object
 */
+ (id)objectFromJSONData:(NSData *)jsonData;

/**
 *  将对象解析为JSON字符串
 *
 *  @param object object
 *
 *  @return JSON String
 */
+ (NSString *)JSONStringFromObject:(id)object;
@end
