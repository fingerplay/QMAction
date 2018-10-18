//
//  QMActionProtocol.h
//  juanpi3
//
//  Created by 罗谨 on 15/7/15.
//  Copyright (c) 2015年 罗谨. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMAction.h"
#import "QMCustomAction.h"
#import "QMPushAction.h"
//#import "QMShareAction.h"

@protocol QMActionProtocol <NSObject>
/**
 *  告诉调用方某个对象是否能处理某种类型的Action
 *
 *  @param action    某种类型的操作
 *
 *  @return 是否能处理
 */
+ (BOOL)canHandleAction:(QMAction*)action;

@optional
/**
 *  根据action创建视图控制器
 *
 *  @param action    跳转的参数，包括content,shareImageUrl,type等字段
 *
 *  @return 创建的视图控制器对象
 */
+ (id)createViewControllerWithAction:(QMAction*)action;

/**
 *  创建视图控制器之后，对其进行的处理，PushAction的默认处理为push跳转,可以不实现这个方法（如果实现的话是在push之前做处理）,CustomAction的需要实现这个方法
 *
 *  @param action 跳转的参数
 *  @param handler 处理action的对象
 */
+ (void)handleAction:(QMAction *)action withHandler:(id)handler;

/**
 *  能否退回到某个页面（使用PushAction，且transitionStyle为TransitionStylePopOrPush时）
 *
 *  @param viewController 从哪个页面退回
 *  @param params         参数
 *
 *  @return 能否退回
 */
- (BOOL)canPopFromViewController:(UIViewController *)viewController withAction:(QMAction*)action;

@end




@protocol QMActionConfigProtocol
/**
 *  根据type获取子类的类别,子类可以重写该方法以获得固定的类别
 *
 *  @param type 跳转类型
 *
 *  @return 子类类别
 */
- (Class)actionSubClassForType:(QMActionType)type;

/**
 *  action对应的页面是否需要先登录才能访问
 *
 *  @return 是否需要登录
 */
- (BOOL)isNeedLogin:(QMAction*)action;


/**
 *  action对应的goodsCollect是否需要记录到数据库中
 *
 *  @return 是否需要记录
 */
- (BOOL)isNeedRecordToDB:(QMAction*)action;
@end
