//
//  QMAction.m
//  juanpi3
//
//  Created by luojin on 15-3-12.
//  Copyright (c) 2015年 luojin. All rights reserved.
//

#import "QMActionManager.h"
#import "QMActionProtocol.h"
#import "QMRuntimeHelper.h"
#import "QMActionManager+Login.h"
#import "QMActionConfig.h"
#import "NSArray+safe.h"
#import "AppDelegate.h"


@interface QMActionManager ()
@property (nonatomic, strong) NSArray *actionClasses;


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
        QMActionConfig *config = [[QMActionConfig alloc] init];
        _config = config;
    }
    return self;
}

- (void)performAction:(QMAction *)action {
    [self performAction:action withSuccess:nil failed:nil];
}

- (void)performAction:(QMAction *)action withSuccess:(QMActionPerformSuccessBlock)succBlock failed:(QMActionPerformFailBlock)failBlock {
    action.succBlock = succBlock;
    action.failBlock = failBlock;
    
    if (!action) {
        NSCAssert(NO, @"action为null!");
        if (failBlock) {
            failBlock(QMActionParamError,nil);
        }
        return;
    }
    
    //注意decode只能执行一次，统一放在外面执行
    NSString *jump_content = action.content;

    //去除url首尾的空格
    if ([jump_content isKindOfClass:[NSString class]]) {
        jump_content = [jump_content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        action.content = jump_content;
    }
    
    __weak typeof(self) weakself = self;
    dispatch_main_async_safe(^(){
        [self checkLoginStatusBeforeAction:action completion:^(BOOL succ) {
            __strong typeof(self) strongself = weakself;
            if (succ) {
                Class<QMActionProtocol> actionClass = [self findClassForAction:action];
                if (actionClass) {
                    [strongself.config registerClass:actionClass forAction:action];
                    
                    [self performAction:action withClass:actionClass success:succBlock failed:failBlock];
                    
                } else {
                    if (failBlock) {
                        failBlock(QMActionClassNotFound,nil);
                    }
                }
            }else{
                if (failBlock) {
                    failBlock(QMActionParamNotMatchError,nil);
                }
            }
        }];
    });

}

- (void)getTargetForAction:(QMAction *)action completion:(QMActionGetTargetBlock)block{
    Class<QMActionProtocol> actionClass = [self findClassForAction:action];
    [self getTargetForAction:action withClass:actionClass completion:^(id target, BOOL isCreated) {
        if (block) {
            block(target,isCreated);
        }
    }];
}

- (Class<QMActionProtocol>)findClassForAction:(QMAction *)action {
    NSString *key = [self.config cacheMapKeyForAction:action];
    Class cacheClass = [self.config.classMapCache objectForKey:key];
    if (cacheClass) {
        //已经缓存的类型，可以直接跳转
        return cacheClass;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
        //未缓存的，先判断该种类型的跳转能被哪个类响应,并缓存下来，再执行跳转
        Class<QMActionProtocol> responseClass = nil;
        for (Class<QMActionProtocol> actionClass in self.actionClasses) {
            BOOL canHandle = NO;
            if ([actionClass respondsToSelector:@selector(canHandleAction:)]) {
                canHandle = [actionClass canHandleAction:action];
            }
           
            if (canHandle) {
                responseClass = actionClass;
                break;
            }
        }
        //如果某个类被动态指定为该action对应的类，则以动态注册的为准
        return responseClass;
#pragma clang diagnostic pop
    }
    return nil;
}

- (void)checkLoginStatusBeforeAction:(QMAction *)action completion:(void (^)(BOOL))completion {
    //检查登录状态，如果没有登录，就先登录
    if ([self shouldPerformLoginBeforeAction:action]) {
        [self performLoginWithAction:action completion:^(BOOL succ) {
            if (completion) {
                completion(succ);
            }
        }];
    }else if (![self isLoginParamMatchWithParams:action.loginParam]) {
        if (completion) {
            completion(NO);
        }
    }else{
        if (completion) {
            completion(YES);
        }
    }
}


- (void)performAction:(QMAction *)action withClass:(Class<QMActionProtocol>)actionClass success:(QMActionPerformSuccessBlock)succBlock failed:(QMActionPerformFailBlock)failBlock {

    //获取视图控制器，并对其属性进行赋值
    dispatch_main_async_safe(^(){
        [self getTargetForAction:action withClass:actionClass completion:^void(id target, BOOL isCreated) {
            if (!target) {
                if (failBlock) {
                    failBlock(QMActionTargetNotFound,nil);
                }
                return;
            }
            
            //当页面再次出现的时候做一些操作
            if (!isCreated && [target respondsToSelector:@selector(viewAppearOnceAgainWithAction:)]) {
                [target performSelector:@selector(viewAppearOnceAgainWithAction:) withObject:action];
            }
            
            
            [action setValuesForObject:target];
            
            //处理各个页面特殊的操作,CustomAction必须要实现此方法
            if ([actionClass respondsToSelector:@selector(handleAction:withHandler:)]) {
                BOOL businessSucc = [actionClass handleAction:action withHandler:target];
                if (!businessSucc && failBlock) {
                    failBlock(QMActionHandleError,nil);
                }
            }
            
            //执行跳转
            if ([target isKindOfClass:[UIViewController class]] && [action isKindOfClass:[QMPushAction class]]) {
                [self performPushAction:(QMPushAction *)action withViewController:target success:succBlock failed:failBlock];
            }else {
                if (succBlock) {
                    succBlock(target,nil);
                }
            }
        }];
    });
}

- (void)getTargetForAction:(QMAction *)action withClass:(Class<QMActionProtocol>)actionClass completion:(QMActionGetTargetBlock)block{
    BOOL shouldCreate = YES;
    id target = nil;

    if ([action isKindOfClass:[QMCustomAction class]]) {
        target = ((QMCustomAction*)action).target;
        if (target && block) {
            block(target, NO);
            return;
        }
    }
    
    if ([actionClass respondsToSelector:@selector(shouldCreateTargetWithAction:)]) {
        shouldCreate = [actionClass shouldCreateTargetWithAction:action];
    }
    
    if (shouldCreate) {
        //创建页面
        if ([actionClass respondsToSelector:@selector(createTargetWithAction:)]) {
            target = [actionClass performSelector:@selector(createTargetWithAction:) withObject:action];
            
        }
    }else {
        //获取一个共享的实例
        if ([actionClass respondsToSelector:@selector(sharedTargetForAction:)]) {
            target = [actionClass performSelector:@selector(sharedTargetForAction:) withObject:actionClass];
        }

    }
    
    if (block) {
        block(target,shouldCreate);
    }
}

- (void)performPushAction:(QMPushAction*)action withViewController:(UIViewController *)publicVC success:(QMActionPerformSuccessBlock)succBlock failed:(QMActionPerformFailBlock)failBlock {
    if (!action.jumpController && [action isKindOfClass:[QMPushAction class]]) {
        //默认为根视图导航栏
        NSCAssert(NO, @"必须设置一个jumpController");
        if (failBlock) {
            failBlock(QMActionParamError,nil);
        }
        return;
    }
    NSLog(@"action transitionType:%@",action.transitionStyle);
    //present方式
    if (action.transitionStyle.integerValue == TransitionStylePresentWithoutNavigationBar) {
        //先把alertView关闭再弹出新的页面，否则无法弹出
        if ([action.jumpController.presentedViewController isKindOfClass:[UIAlertController class]]) {
            [action.jumpController dismissViewControllerAnimated:YES completion:^{
                [action.jumpController presentViewController:publicVC animated:YES completion:^{
                    if (succBlock) {
                        succBlock(publicVC,nil);
                    }
                }];
            }];
        }else {
            [action.jumpController presentViewController:publicVC animated:YES completion:^{
                if (succBlock) {
                    succBlock(publicVC,nil);
                }
            }];
        }
    }
    else if (action.transitionStyle.integerValue == TransitionStylePresent) {
        UIViewController *prestingController = action.jumpController;
        
        if ([action.jumpController.presentedViewController isKindOfClass:[UIAlertController class]]) {
            [action.jumpController dismissViewControllerAnimated:YES completion:^{
                UINavigationController *baseNC = [[UINavigationController alloc] initWithRootViewController:publicVC];
                [prestingController presentViewController:baseNC animated:YES completion:^{
                    if (succBlock) {
                        succBlock(publicVC,nil);
                    }
                }];
            }];
        }else{
            UINavigationController *baseNC = [[UINavigationController alloc] initWithRootViewController:publicVC];
            [prestingController presentViewController:baseNC animated:YES completion:^{
                if (succBlock) {
                    succBlock(publicVC,nil);
                }
            }];
        }
        
    }
    //push或pop方式
    else if ([action.jumpController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navControl = (UINavigationController *)action.jumpController;
        //普通推入跳转
        if(action.transitionStyle.integerValue == TransitionStyleNormalPush){
            //防止重复打开同一个页面
            if ([navControl.topViewController isKindOfClass:[UIViewController class]]) {
                [navControl pushViewController:publicVC animated:YES];
                if (succBlock) {
                    succBlock(publicVC,nil);
                }
            }else {
                if (failBlock) {
                    failBlock(QMActionParamError,nil);
                }
            }
        }
        //弹回到某一页或者推入
        else if (action.transitionStyle.integerValue == TransitionStylePopOrPush ) {
            UIViewController *lastVC = [navControl.viewControllers safeObjectAtIndex:navControl.viewControllers.count - 1];
            for (NSInteger i = navControl.viewControllers.count - 2; i >=0; i--) {
                UIViewController *vc = [navControl.viewControllers objectAtIndex:i];
                if ([vc isKindOfClass:[publicVC class]] && [vc respondsToSelector:@selector(canPopFromViewController:withAction:)] ) {
                    BOOL canPop = [(id<QMActionProtocol>)vc canPopFromViewController:lastVC withAction:action];
                    if (canPop) {
                        [navControl popToViewController:vc animated:YES];
                        if (succBlock) {
                            succBlock(publicVC,nil);
                        }
                    }
                  
                } else if ([vc isKindOfClass:[publicVC class]]) {
                    [action setValuesForObject:vc];
                    [navControl popToViewController:vc animated:YES];
                    if (succBlock) {
                        succBlock(publicVC,nil);
                    }
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [navControl pushViewController:publicVC animated:YES];
                if (succBlock) {
                    succBlock(publicVC,nil);
                }
            });
        }else if (action.transitionStyle.integerValue == TransitionStylePopToHomeAndPresent) {
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                if ([action.jumpController.presentedViewController isKindOfClass:[UIAlertController class]]) {
                    [action.jumpController dismissViewControllerAnimated:YES completion:^{
                        UINavigationController *baseNC = [[UINavigationController alloc] initWithRootViewController:publicVC];
                        [navControl presentViewController:baseNC animated:YES completion:^{
                            if (succBlock) {
                                succBlock(publicVC,nil);
                            }
                        }];
                    }];
                }else{
                    UINavigationController *baseNC = [[UINavigationController alloc] initWithRootViewController:publicVC];
                    [navControl presentViewController:baseNC animated:YES completion:^{
                        if (succBlock) {
                            succBlock(publicVC,nil);
                        }
                    }];
                }
                
            });
        }
        
    }
    //其他不支持类型
    else {
        NSCAssert(NO, @"不支持该类型的跳转!");
        if (failBlock) {
            failBlock(QMActionParamError,nil);
        }
    }
}


@end
