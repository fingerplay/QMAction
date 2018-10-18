//
//  QMAction.h
//  juanpi3
//
//  Created by songbiao on 15-3-12.
//  Copyright (c) 2015年 songbiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMActionProtocol.h"
#import "QMJSONManager.h"
#import "QMActionDefine.h"

@interface QMActionManager : NSObject

//QMAction配置，如果不设置会取默认配置
@property (nonatomic, strong) id<QMActionConfigProtocol> config;

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
 *  @return BOOL 是否成功跳转，返回NO代表未跳转或先跳到了其他页面，等待用户操作后才可以跳转到指定页面
 */
- (BOOL)performAction:(QMAction *)action;

/**
 *  根据跳转的类型创建对应的页面
 *
 *  @param action 跳转参数，包括type，content等
 *  @return target action对应的页面
 */
- (id)createTargetForAction:(QMAction *)action;



@end
