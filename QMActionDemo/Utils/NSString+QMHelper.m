//
//  NSString+QMHelper.m
//  juanpi3
//
//  Created by Jay on 16/1/15.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import "NSString+QMHelper.h"

@implementation NSString (QMHelper)

- (NSNumber*)verToNumber{
    
    if (!self) {
        return @(0);
    }
    NSMutableString * string = [NSMutableString stringWithString:self];
    NSRange range = [string rangeOfString:@"."];
    
    [string replaceOccurrencesOfString:@"." withString:@"" options:NSCaseInsensitiveSearch range:NSRangeFromString([NSString stringWithFormat:@"{%lu,%lu}", (unsigned long)range.location+1, (unsigned long)self.length-range.location-1])];
    
    return [NSNumber numberWithFloat:[string floatValue]];
}

- (BOOL)isHTTPLink {
    if ([self isKindOfClass:[NSString class]]) {
        if (self.length > 0 && ([self hasPrefix:@"http://"] || [self hasPrefix:@"https://"])) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isNormalHTTPLink {
    if ([self isKindOfClass:[NSString class]] && self.length > 0 && ([self hasPrefix:@"http://"] || [self hasPrefix:@"https://"])) {
        if ([self rangeOfString:@"http://go_login"].location == NSNotFound && [self rangeOfString:@"http://go_share"].location == NSNotFound) {
            return YES;
        }
    }

    return NO;
}

- (BOOL)isJSNull {
    if (self.length == 0 || [self isEqualToString:@"null"] || [self isEqualToString:@"undefined"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)cutSearchKeywordsForJump:(NSString *)keywords
{
    //截取 url 最后一部分
    NSString *lastComponent = [keywords lastPathComponent];
    NSMutableString *targetUrl = [NSMutableString string];
    
    NSUInteger keywordsLength = lastComponent.length;
    
    //拼接url最后的部分中的数字和“_”
    for (int index = 0; index < keywordsLength; index ++) {
        
        UniChar keyword = [lastComponent characterAtIndex:index];
        if (keyword >= 48 && keyword <= 57) {
            NSString *chString = [NSString stringWithFormat:@"%c",keyword];
            [targetUrl appendString:chString];//拼接数字
        }
        
        if (keyword == 63) {//将 '?xxxx=' ---> '_'
            [targetUrl appendString:@"_"];//拼接 "_"
        }
    }
    
    return targetUrl;
}

- (NSString *)filterHtml
{
    NSString *result = self;
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:result];
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"<" intoString:NULL];
        [theScanner scanUpToString:@">" intoString:&text];
        result = [result stringByReplacingOccurrencesOfString:
                  [ NSString stringWithFormat:@"%@>", text]
                                                   withString:@""];
    }
    return result;
}


- (NSString *)setupHidePhoneNum {
    if (![self isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *returnString = nil;
    
    if (self.length >= 7) {
        returnString = [self stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    else {
        returnString = self;
    }
    return returnString;
}


- (NSString *)setupHideEmail {
    if (![self isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString *returnString = nil;
    
    if ([self rangeOfString:@"@"].location != NSNotFound) {
        NSArray *emailArr = [self componentsSeparatedByString:@"@"];
        NSString *headStr = [emailArr objectAtIndex:0];
        if (headStr.length > 2) {
            returnString = [self stringByReplacingCharactersInRange:NSMakeRange(headStr.length - 2, 2) withString:@"**"];
        }
        else {
            NSString *replaceString = @"*";
            if (headStr.length == 2) {
                replaceString = @"**";
            }
            returnString = [self stringByReplacingCharactersInRange:NSMakeRange(0, headStr.length) withString:replaceString];
        }
    }
    else {
        returnString = self;
    }
    
    return returnString;
}

- (NSString *)replaceSchemeToHttpsIfNeed {
    if (![self isKindOfClass:[NSString class]]) {
        return nil;
    }
    return self;
    
//--------------- 苹果强制要求开启ATS时候在此进行替换操作 ---------------
//    //以下域名不替换
//    if ([self rangeOfString:@"drp.juanpi.com"].location != NSNotFound
//        || [self rangeOfString:@"dmall.juanpi.com"].location != NSNotFound) {
//        return self;
//    }
//    if ([self isHTTPLink]) {
//        if ([self hasPrefix:@"http://"]) {
//            return [self stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
//        } else {
//            return self;
//        }
//    } else {
//        return [NSString stringWithFormat:@"https://%@",self];
//    }
}


- (UIImage *)base64StringtoImg {
    NSData *imageData = [[NSData alloc] initWithBase64Encoding:self];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}



- (NSDictionary *)dictionary{
    if (![self isKindOfClass:[NSString class]] || self.length <= 0) {
        return nil;
    }
    NSString *baseString = self;
    NSData *jsonData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return nil;
    }
    return dic;
}

@end
