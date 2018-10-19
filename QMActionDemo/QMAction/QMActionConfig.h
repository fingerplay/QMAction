//
//  QMAction+Login.h
//  juanpi3
//
//  Created by 罗谨 on 2017/8/9.
//  Copyright © 2017年 罗谨. All rights reserved.
//

#import "QMAction.h"
#import "QMActionProtocol.h"

@interface QMActionConfig : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *classMapCache;

/**
 *  根据type获取子类的类别,子类可以重写该方法以获得固定的类别
 *
 *  @param type 跳转类型
 *  @param module 模块名称
 *
 *  @return 子类类别
 */
- (Class)actionSubClassForType:(QMActionType)type module:(NSString*)module;

/**
 *  action对应的页面是否需要先登录才能访问
 *
 *  @param action 跳转类型
 *
 *  @return 是否需要登录
 */
- (BOOL)isNeedLogin:(QMAction*)action;

/**
 *  action对应的缓存字段的key
 *
 *  @param action 跳转类型
 *
 *  @return key
 */
- (NSString*)cacheMapKeyForAction:(QMAction*)action;


/**
 *  动态注册一个action的class
 *
 *  @param cls 动态注册的类
 *  @param action 跳转参数，包括type，content等
 *  @discussion 该方法会覆盖canHandleAction所指定的class
 */
- (void)registerClass:(Class<QMActionProtocol>)cls forAction:(QMAction *)action;

@end
