//
//  QMAction.h
//  juanpi3
//
//  Created by luojin on 15-3-12.
//  Copyright (c) 2015年 songbiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMActionProtocol.h"
#import "QMActionDefine.h"
#import "QMActionConfig.h"
#import "SHMacroDefine.h"

@interface QMActionManager : NSObject

//QMAction配置，如果不设置会取默认配置
@property (nonatomic, strong) QMActionConfig* config;

/**
*  返回QMAction的公共实例
*
*  @return 公共实例
*/
+ (instancetype)sharedManager;


/**
 *  执行某个跳转方法
 *
 *  @param action 跳转参数，包括type，content等
 *  @param succBlock 跳转成功的回调函数
 *  @param failBlock 跳转失败的回调函数
 */
- (void)performAction:(QMAction *)action withSuccess:(QMActionPerformSuccessBlock)succBlock failed:(QMActionPerformFailBlock)failBlock;


- (void)performAction:(QMAction *)action;

/**
 *  查找action对应的class
 *
 *  @param action 跳转参数，包括type，content等
 *
 */
- (Class<QMActionProtocol>)findClassForAction:(QMAction *)action;

/**
 *  根据跳转的类型获取对应的页面
 *
 *  @param action 跳转参数，包括type，content等
 *  @param block  回调函数
 */
- (void)getTargetForAction:(QMAction *)action completion:(QMActionGetTargetBlock)block;



@end
