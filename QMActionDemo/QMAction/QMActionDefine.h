//
//  QMDefine.h
//  juanpi3
//
//  Created by 罗谨 on 2017/8/9.
//  Copyright © 2017年 罗谨. All rights reserved.
//


#define ACTION_SCHEME  @"qimi"
#define ACTION_MODULE_HOME @"home"
#define ACTION_MODULE_NORMAL @"normal"


#define ACTION_PARAM_SOURCE  @"source"
#define ACTION_PARAM_SUCCURL @"succ"
#define ACTION_PARAM_FAILURL @"fail"
#define ACTION_PARAM_TRANSITIONSTYLE @"tranStyle"
#define ACTION_PARAM_LOGINPARAM  @"login"
#define ACTION_PARAM_CONTENT @"content"
#define ACTION_PARAM_TYPE @"type"

typedef NS_ENUM(NSInteger, QMActionType){
    QMActionTypeDefaultWebVC = 1,                       //加载网页
};


typedef NS_ENUM(NSInteger,QMActionSourceType) {
    QMActionSourceTypeDefault = 0, //本地唤起
    QMActionSourceTypeWebView,  //webview页面唤起
    QMActionSourceTypeRemoteNotification,  //推送消息唤起
    QMActionSourceTypeLocalNotification,  //本地消息唤起
    QMActionSourceTypeOutsideApp, //外部APP唤起,包括safari
    QMActionSourceTypeNetworkResponse, //网络请求结果唤起
};

typedef NS_ENUM(NSInteger,QMActionErrorCode) {
    QMActionParamError = 0, //action参数错误，导致无法调用，一般是content或者是jumpController错误
    QMActionClassNotFound = -1,  //没有类可以响应这个action，一般是type不对
    QMActionTargetNotFound = -2, //没有对象可以响应这个action，一般是已经创建过的对象无法找到。
    QMActionParamNotMatchError = -3, //由于登录流程中某一步获取的数据与参数不匹配导致的失败
    QMActionHandleError = -4, //业务失败，这种情况其实action调用成功了，只是handleAction方法内部返回了失败
};


typedef void(^QMActionPerformSuccessBlock)(id target,NSDictionary* userInfo);
typedef void(^QMActionPerformFailBlock)(QMActionErrorCode errorCode,NSDictionary *userInfo);
typedef void(^QMActionGetTargetBlock)(id target,BOOL isCreated);


