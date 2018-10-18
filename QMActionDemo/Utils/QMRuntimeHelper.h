//
//  QMRuntimeHelper.h
//  juanpi3
//
//  Created by 罗谨 on 15/6/24.
//  Copyright (c) 2015年 罗谨. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RuntimeHookBlock)(id ,NSArray *);

@interface QMRuntimeHelper : NSObject

/**
 *  用一个新的方法替换类中的一个已经存在的方法
 *
 *  @param class            要修改的类
 *  @param originalSelector 要替换的方法的选择器
 *  @param swizzledSelector 新方法的选择器
 *  @param isInstanceMethod 是否实例方法
 */
+ (void)setMethodSwizzlingForClass:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector isInstanceMethod:(BOOL)isInstanceMethod;

/**
 *  在运行时判断类中是否包含某个属性
 *
 *  @param class        类
 *  @param propertyName 属性名
 *
 *  @return 该属性是否存在
 */
+ (BOOL)isClass:(Class)class hasProperty:(NSString*)propertyName;

/**
 *  在运行时判断类中是否包含某个实例方法，类似于NSObject的instanceRespondsToSelector
 *
 *  @param class              类
 *  @param instanceMethodName 方法名
 *
 *  @return 该方法是否存在
 */
+ (BOOL)isClass:(Class)class hasInstanceMethod:(NSString*)instanceMethodName;

/**
 *  在运行时判断类中是否包含某个类方法
 *
 *  @param class           类
 *  @param classMethodName 方法名
 *
 *  @return 该方法是否存在
 */
+ (BOOL)isClass:(Class)class hasClassMethod:(NSString *)classMethodName;

/**
 *  在运行时判断一个类是否存在
 *
 *  @param className 类名
 *
 *  @return 是否存在
 */
+ (BOOL)isClassExist:(NSString *)className;

/**
 *  修改类中的一个方法，往里面添加一些代码（本质上是方法置换）
 *
 *  @param class              要修改的类
 *  @param originalMethodName 要修改的方法名
 *  @param isInstanceMethod   是否实例方法
 *  @param block              增加的代码
 *
 *  @return 是否添加成功
 */
+ (BOOL)hookMethodForClass:(Class)class originalMethod:(NSString*)originalMethodName isInstanceMethod:(BOOL)isInstanceMethod hookedBlock:(RuntimeHookBlock)block;

/**
 *  获取类中某个方法的实现block
 *
 *  @param class          类
 *  @param methodSelector 方法选择器
 *
 *  @return 该方法对应的block
 */
+ (id)methodBlockForClass:(Class)class method:(SEL)methodSelector;

/**
 *  获取所有遵循了指定协议的类
 *
 *  @param protocol 要遵循的协议
 *
 *  @return 遵循了协议的类
 */
+ (NSArray *)getClassesThatConfirmToProtocol:(Protocol*)protocol;

@end
