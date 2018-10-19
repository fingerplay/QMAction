//
//  QMAction.h
//  juanpi3
//
//  Created by 罗谨 on 15/7/16.
//  Copyright (c) 2015年 罗谨. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMActionDefine.h"




@interface QMAction : NSObject

/**
 *  跳转模块，必填项
 */
@property (nonatomic, strong) NSString *module;

/**
 *  跳转类型，必填项
 */
@property (nonatomic, assign) QMActionType type;


/**
 *  子类型,非必填
 */
@property (nonatomic, assign) NSInteger subtype;


/**
 *  跳转的content参数，对于web页面来说是跳转的url，对于一般页面来说是参数
 */
@property (nonatomic, copy) NSString *content;

/**
 *  跳转的content参数，对content进行json的解析的结果
 */
@property (nonatomic, strong) NSMutableDictionary *contentDict;


/**
 *  自定义参数，QMActionManager会根据其key-Value进行属性的赋值
 */
@property (nonatomic, strong) NSDictionary *userInfo;
/**
 *  跳转的控制器，对于pushAction来说必填，一般是UINavigationController，对于特殊的跳转动画，也可以是其他的UIViewController，customAction在大多数情况下也需要
 */
@property (nonatomic, weak) UIViewController *jumpController;

/**
 *  跳转来源，具体到url或app名称
 */
@property (nonatomic, copy) NSString *source;

/**
 *  需要先登录再跳转
 */
@property (nonatomic, strong) NSDictionary *loginParam;

/**
 *  成功后跳转的url
 */
@property (nonatomic, copy) NSString *succUrl;

/**
 *  失败后跳转的url
 */
@property (nonatomic, copy) NSString *failUrl;

/**
 *  成功回调block
 */
@property (nonatomic, copy) QMActionPerformSuccessBlock succBlock;

/**
 *  失败回调block
 */
@property (nonatomic, copy) QMActionPerformFailBlock failBlock;

/**
 *  跳转来源类型
 */
@property (nonatomic, assign) QMActionSourceType sourceType;

/**
 *  操作从哪个页面发起
 */
@property (nonatomic, weak) UIViewController* sourceViewController;


/**
 qimi 协议
 */
@property (nonatomic, strong) NSString *url;


/**
 *  创建QMAction的工厂方法，建议使用该方法获取并初始化QMAction
 *
 *  @param type          action的类型
 *  @param module        action操作模块
 *  @param content       action的参数
 *  @param jumpControl  控制跳转的视图控制器
 *
 *  @return QMAction的实例，可能是QMPushAction或其他子类
 */
+ (instancetype)actionWithType:(NSInteger)type module:(NSString*)module content:(NSString *)content jumpController:(UIViewController*)jumpControl;

+ (instancetype)actionWithType:(NSInteger)type module:(NSString*)module content:(NSString *)content;

+ (instancetype)actionWithType:(NSInteger)type module:(NSString*)module contentDict:(NSDictionary *)contentDict jumpController:(UIViewController*)jumpControl;

/**
 *  解析Url得到Action
 *
 *  @param jump_url 要解析的Url
 *  @param jumpController 跳转控制器
 *
 *  @return 根据type值确定的Action,可能是PushAction,CustomAction或者ShareAction。千万不要用Action子类调用该方法!!
 */
+ (instancetype)actionFromUrl:(NSString *)jump_url jumpController:(UIViewController*)jumpController;



/**
 *  根据action的userInfo参数自动填充object对象的属性的值,userInfo里面的key必须为字符串类型
 *
 *  @param object 要填充的对象
 */
- (void)setValuesForObject:(id)object;

@end
