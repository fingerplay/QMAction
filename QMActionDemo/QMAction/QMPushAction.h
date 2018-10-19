//
//  QMPushAction.h
//  juanpi3
//
//  Created by 罗谨 on 15/7/17.
//  Copyright (c) 2015年 罗谨. All rights reserved.
//

#import "QMAction.h"

typedef NS_ENUM(NSInteger, TransitionStyle){
    TransitionStyleNormalPush = 0,//普通跳转,[navigationController pushViewController]
    TransitionStylePopOrPush, // 当导航栏中有待跳转的页面时，会自动回到那一页，否则推入一个新的页面
    TransitionStylePopToHomeAndPush, //先回到首页，然后推入新的页面
    TransitionStylePresent, //从下往上弹出视图，自带导航栏
    TransitionStylePopToHomeAndPresent, //先回到首页，然后弹出一个视图
    TransitionStylePresentWithoutNavigationBar, //从下往上弹出视图，没有导航栏
    TransitionStyleCustom, //自定义的跳转
};

@interface QMPushAction : QMAction

@property (nonatomic, strong) NSNumber* transitionStyle;

@end
