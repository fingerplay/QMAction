//
//  QMAction.m
//  juanpi3
//
//  Created by songbiao on 15-3-12.
//  Copyright (c) 2015年 songbiao. All rights reserved.
//

#import "QMActionManager.h"
#import "QMActionProtocol.h"
#import "QMRuntimeHelper.h"
#import "QMActionManager+Login.h"
#import "QMActionConfig.h"
#import "NSArray+safe.h"

//H5跳转交互，业务：http://wiki.juanpi.org/pages/viewpage.action?pageId=3703108

@interface QMActionManager ()
@property (nonatomic, strong) NSArray *actionClasses;
@property (nonatomic, strong) NSCache *classMapCache;

@end

QMActionManager *_sharedInstance = nil;
@implementation QMActionManager

+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[QMActionManager alloc] init];
    });
    return _sharedInstance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        //动态获取所有遵循了QMActionProtocol的类
        _actionClasses = [QMRuntimeHelper getClassesThatConfirmToProtocol:@protocol(QMActionProtocol)];
        _classMapCache = [[NSCache alloc] init];
        QMActionConfig *config = [[QMActionConfig alloc] init];
        _config = config;
    }
    return self;
}

- (BOOL)performAction:(QMAction *)action {
    
    if (!action) {
        NSCAssert(NO, @"action为null!");
        return NO;
    }
    
    NSInteger indexType = action.type;
    if (!indexType) {
        NSCAssert(NO, @"type为0!");
        return NO;
    }
    
    //注意decode只能执行一次，统一放在外面执行
    NSString *jump_content = action.content;

    //去除url首尾的空格
    if ([jump_content isKindOfClass:[NSString class]]) {
        jump_content = [jump_content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        action.content = jump_content;
    }
    
    
    //检查登录状态，如果没有登录，就先登录
    if([self shouldPerformLoginBeforeAction:action]) {
        __weak typeof(self) wSelf = self;
        [wSelf performAction:action afterLogin:^{
            __strong typeof(self) sSelf = self;
            Class actionClass = [sSelf findClassForAction:action];
            if (actionClass) {
                [sSelf performAction:action withClass:actionClass];
            }
        }];
        return NO;
    } else {
        Class actionClass = [self findClassForAction:action];
        if (actionClass) {
            [self performAction:action withClass:actionClass];
            return YES;
        } else {
            return NO;
        }
    }
}

- (id)createTargetForAction:(QMAction *)action {
    Class actionClass = [self findClassForAction:action];
    id target = [self createTargetForAction:action withClass:actionClass];
    return target;
}

- (Class)findClassForAction:(QMAction *)action {
    Class cacheClass = [self.classMapCache objectForKey:@(action.type)];
    if (cacheClass) {
        //已经缓存的类型，可以直接跳转
        return cacheClass;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
        //未缓存的，先判断该种类型的跳转能被哪个类响应,并缓存下来，再执行跳转
        for (Class<QMActionProtocol> actionClass in self.actionClasses) {
            BOOL canHandle = [actionClass performSelector:@selector(canHandleAction:) withObject:action];
            if (canHandle) {
                [self.classMapCache setObject:actionClass forKey:@(action.type)];
                return actionClass;
            }
        }
#pragma clang diagnostic pop
    }
    return nil;
}


- (BOOL)performAction:(QMAction *)action withClass:(Class)actionClass {
    //创建视图控制器，并对其属性进行赋值
    id target = [self createTargetForAction:action withClass:actionClass];

    //处理各个页面特殊的操作,CustomAction必须要实现此方法
    if ([actionClass respondsToSelector:@selector(handleAction:withHandler:)]) {
        [actionClass performSelector:@selector(handleAction:withHandler:) withObject:action withObject:target];
    }
    
    //执行跳转
    if (target && [target isKindOfClass:[UIViewController class]] && [action isKindOfClass:[QMPushAction class]]) {
        return [self performPushAction:(QMPushAction *)action withViewController:target];
    }
    return YES;
}

- (id)createTargetForAction:(QMAction *)action withClass:(Class)actionClass{
    
    
    id result;
    //创建页面
    if ([actionClass respondsToSelector:@selector(createViewControllerWithAction:)]) {
        result = [actionClass performSelector:@selector(createViewControllerWithAction:) withObject:action];

    }
    //没有实现createViewControllerWithAction：方法的，默认创建一个viewController（注意父类有没有实现createViewController方法）
    else if ([actionClass isSubclassOfClass:[UIViewController class]]) {
        result = [[actionClass alloc] init];
    }
    
    if (result){
        [action setValuesForObject:result];
    }
    
    return result;
}

- (BOOL)performPushAction:(QMPushAction*)action withViewController:(UIViewController *)publicVC {
    if (!action.jumpController && [action isKindOfClass:[QMPushAction class]]) {
        NSCAssert(NO, @"必须设置一个jumpController");
//        action.jumpController =  [QMAppUtils currentNavController];
    }
    //present方式
    if (action.transitionStyle.integerValue == TransitionStylePresentWithoutNavigationBar) {
        [action.jumpController presentViewController:publicVC animated:YES completion:nil];
    }
    else if (action.transitionStyle.integerValue == TransitionStylePresent) {
        UIViewController *prestingController = action.jumpController;
        UINavigationController *baseNC = [[UINavigationController alloc] initWithRootViewController:publicVC];
        [prestingController presentViewController:baseNC animated:YES completion:nil];
    }
    //push或pop方式
    else if ([action.jumpController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navControl = (UINavigationController *)action.jumpController;
        //导航栏跟随页面跳转，例如首页浮窗跳转到个人中心
        if (action.transitionStyle.integerValue == TransitionStyleNavigationPush) {
            if ([navControl.topViewController isKindOfClass:[UIViewController class]]) {
                [navControl pushViewController:publicVC animated:YES];
            } else {
                return NO;
            }
        }
        
        //普通推入跳转
        else if(action.transitionStyle.integerValue == TransitionStyleNormalPush){
            //防止重复打开同一个页面
            if ([navControl.topViewController isKindOfClass:[UIViewController class]]) {
                [navControl pushViewController:publicVC animated:YES];
            }else {
                return NO;
            }
        }
        //弹回到某一页或者推入
        else if (action.transitionStyle.integerValue == TransitionStylePopOrPush ) {
            UIViewController *lastVC = [navControl.viewControllers safeObjectAtIndex:navControl.viewControllers.count - 1];
            for (NSInteger i = navControl.viewControllers.count - 2; i >=0; i--) {
                UIViewController *vc = [navControl.viewControllers objectAtIndex:i];
                if ([vc isKindOfClass:[publicVC class]] && [vc respondsToSelector:@selector(canPopFromViewController:withAction:)] ) {
                    BOOL canPop = [vc performSelector:@selector(canPopFromViewController:withAction:) withObject:lastVC withObject:action];
                    if (canPop) {
                        [navControl popToViewController:vc animated:YES];
                        return YES;
                    }
                  
                } else if ([vc isKindOfClass:[publicVC class]]) {
                    [navControl popToViewController:vc animated:YES];
                    return YES;
                }
            }
            
            [navControl pushViewController:publicVC animated:YES];
        }
        //回到首页再跳转
        else if (action.transitionStyle.integerValue == TransitionStylePopToHomeAndPush ) {
            //默认跳转延时
            float sec =  1.3;
            //当导航栏大于6个控制器时  控制器单个移除延时。
            float psec = 0.15;
            
            NSInteger maxCount = 6;
            NSInteger navCount = [navControl.viewControllers count];
            
            if (navCount > maxCount) {
                sec = sec + (navCount - maxCount) * psec;
            }
            [navControl popToRootViewControllerAnimated:NO];
//            [QMLoadView showToView:[[UIApplication sharedApplication] delegate].window.rootViewController.view animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//               [QMLoadView hideForView:[[UIApplication sharedApplication] delegate].window.rootViewController.view animated:YES];
               [navControl pushViewController:publicVC animated:YES];
            });
        }else if (action.transitionStyle.integerValue == TransitionStylePopOrPushIsExist){
            for (NSInteger i = navControl.viewControllers.count - 2; i >=0; i--) {
                UIViewController *vc = [navControl.viewControllers objectAtIndex:i];
                if ([vc isKindOfClass:[publicVC class]] && [vc respondsToSelector:@selector(canPopFromViewController:withAction:)] ) {
                    BOOL canPop = [vc performSelector:@selector(canPopFromViewController:withAction:) withObject:vc withObject:action];
                    if (canPop) {
                        [navControl popToViewController:vc animated:YES];
                        return YES;
                    }
                    
                } else if ([vc isKindOfClass:[publicVC class]]) {
                    [navControl popToViewController:vc animated:YES];
                    [action setValuesForObject:vc];
                    return YES;
                }
            }
            
            [navControl pushViewController:publicVC animated:YES];
            
        }
    }
    //其他不支持类型
    else {
        NSCAssert(NO, @"不支持该类型的跳转!");
        return NO;
    }
    return YES;
}


@end
