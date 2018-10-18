//
//  NSArray+safe.m
//  Juanpi
//
//  Created by huang jiming on 13-1-17.
//  Copyright (c) 2013年 Juanpi. All rights reserved.
//

#import "NSArray+safe.h"
#import "QMRuntimeHelper.h"
#import <objc/runtime.h>

@implementation NSArray (Safe)

+ (void)load
{
//    [self overrideMethod:@selector(objectAtIndexedSubscript:) withMethod:@selector(safeObjectAtIndexedSubscript:)];
//    [objc_getClass("__NSPlaceholderArray") exchangeMethod:@selector(initWithObjects:count:) withMethod:@selector(safeInitWithObjects:count:)];
    [QMRuntimeHelper setMethodSwizzlingForClass:[self class] originalSelector:@selector(objectAtIndexedSubscript:)  swizzledSelector:@selector(safeObjectAtIndexedSubscript:) isInstanceMethod:YES];
    [QMRuntimeHelper setMethodSwizzlingForClass:objc_getClass("__NSPlaceholderArray") originalSelector:@selector(initWithObjects:count:) swizzledSelector:@selector(safeInitWithObjects:count:) isInstanceMethod:YES];
}

- (id)safeObjectAtIndexedSubscript:(NSUInteger)index
{
    if (index >= self.count) {
        return nil;
    } else {
        return [self objectAtIndex:index];
    }
}

- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        return nil;
    } else {
        return [self objectAtIndex:index];
    }
}

+ (instancetype)safeArrayWithObject:(id)object
{
    if (object == nil) {
        return [self array];
    } else {
        return [self arrayWithObject:object];
    }
}

- (instancetype)safeInitWithObjects:(const id  _Nonnull     __unsafe_unretained *)objects count:(NSUInteger)cnt
{
    BOOL hasNilObject = NO;
    for (NSUInteger i = 0; i < cnt; i++) {
        if (objects[i] == nil) {
            hasNilObject = YES;
#if DEBUG
            NSString *errorMsg = [NSString stringWithFormat:@"数组元素不能为nil，其index为: %lu", (unsigned long)i];
            NSCAssert(objects[i] != nil, errorMsg);
#endif
        }
    }
    
    // 过滤掉值为nil的元素
    if (hasNilObject) {
        id __unsafe_unretained newObjects[cnt];
        NSUInteger index = 0;
        for (NSUInteger i = 0; i < cnt; ++i) {
            if (objects[i] != nil) {
                newObjects[index++] = objects[i];
            }
        }
        return [self safeInitWithObjects:newObjects count:index];
    }
    return [self safeInitWithObjects:objects count:cnt];
}


- (NSMutableArray *)mutableDeepCopy
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:self.count];
    
    for(id oneValue in self) {
        id oneCopy = nil;
        
        if([oneValue respondsToSelector:@selector(mutableDeepCopy)]) {
            oneCopy = [oneValue mutableDeepCopy];
        } else if([oneValue conformsToProtocol:@protocol(NSMutableCopying)]) {
            oneCopy = [oneValue mutableCopy];
        } else if([oneValue conformsToProtocol:@protocol(NSCopying)]){
            oneCopy = [oneValue copy];
        } else {
            oneCopy = oneValue;
        }
        
        [returnArray addObject:oneCopy];
    }
    
    return returnArray;
}

- (BOOL)safeKindofElementClass:(Class)elementClass {
    if (![self isKindOfClass:[NSArray class]]) {
        return NO;
    }
    for (id e in self) {
        if (![e isKindOfClass:elementClass]) {
            return NO;
        }
    }
    return YES;
}

@end
