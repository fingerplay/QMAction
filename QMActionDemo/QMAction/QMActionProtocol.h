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
 *  创建视图控制器之后，对其进行的处理，PushAction的默认处理为push跳转,可以不实现这个方法（如果实现的话是在push之前做处理）,CustomAction的需要实现这个方法
 *
 *  @param action 跳转的参数
 *  @param handler 处理action的对象
 *  @return 处理的结果是否成功
 */
+ (BOOL)handleAction:(QMAction *)action withHandler:(id)handler;

/**
 *  告诉调用方是否应该创建对应的VC
 *
 *  @param action    某种类型的操作
 *
 *  @return 是否应该创建
 */
+ (BOOL)shouldCreateTargetWithAction:(QMAction*)action;

/**
 *  根据action创建视图控制器
 *
 *  @param action    跳转的参数，包括content,type等字段
 *
 *  @return 创建的视图控制器对象
 */
+ (id)createTargetWithAction:(QMAction*)action;

/**
 *  给调用方返回共享的实例
 *
 *  @param action    某种类型的操作
 *
 *  @return 共享的实例
 */
+ (id)sharedTargetForAction:(QMAction*)action;

/**
 *  当页面再次出现的时候做的操作
 *
 *  @param action    跳转的参数，包括content,type等字段
 *
 */
- (void)viewAppearOnceAgainWithAction:(QMAction*)action;


/**
 *  当页面离开的时候做的操作(只在切换页面的时候触发)
 *
 *  @param action    跳转的参数，包括content,type等字段
 *
 */
- (void)viewWillDisappearWithAction:(QMAction*)action;

/**
 *  能否退回到某个页面（使用PushAction，且transitionStyle为TransitionStylePopOrPush时）
 *
 *  @param viewController 从哪个页面退回
 *  @param action         参数
 *
 *  @return 能否退回
 */
- (BOOL)canPopFromViewController:(UIViewController *)viewController withAction:(QMAction*)action;


@end


