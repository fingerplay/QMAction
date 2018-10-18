//
//  NSArray+safe.h
//  Juanpi
//
//  Created by huang jiming on 13-1-17.
//  Copyright (c) 2013年 Juanpi. All rights reserved.//ii
//

#import <Foundation/Foundation.h>

@interface NSArray (Safe)

- (id)safeObjectAtIndex:(NSUInteger)index;

+ (instancetype)safeArrayWithObject:(id)object;

- (NSMutableArray *)mutableDeepCopy;

/** 判断子元素是否是elementClass */
- (BOOL)safeKindofElementClass:(Class)elementClass;

@end
