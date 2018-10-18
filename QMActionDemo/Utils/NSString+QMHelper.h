//
//  NSString+QMHelper.h
//  juanpi3
//
//  Created by Jay on 16/1/15.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (QMHelper)

/**
 *  2.2.0 to 2.20
 */
- (NSNumber *)verToNumber;

/**
 *  判断@"http://" or @"https://"  return YES
 */
- (BOOL)isHTTPLink;

/**
 *  判断@"http://" or @"https://"  且不是go_login或者go_share return YES
 */
- (BOOL)isNormalHTTPLink;

/**
 * 处理在搜索框中输入的 m 站地址，比如："http://m.juanpi.com/brand/1369449?shop_id=1988560" 转化为
 *  “1369449_1988560”
 */
+ (NSString *)cutSearchKeywordsForJump:(NSString *)keywords;

/**
 *  给手机号加**号
 */
- (NSString *)setupHidePhoneNum;

/**
 *  给邮箱加**号
 */
- (NSString *)setupHideEmail;
/** 
 *  无协议url和http的
 */
- (NSString *)replaceSchemeToHttpsIfNeed;

- (UIImage *)base64StringtoImg;

- (NSDictionary *)dictionary;

- (BOOL)isJSNull;

@end
