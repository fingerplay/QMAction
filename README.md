# QMAction
一种schema 路由的解决方案。利用runtime机制充分解耦，使得业务模块之间几乎没有依赖。

调用方式
调用url schema 
NSString *actionUrl = @"beehome://device?type=0&content=%7b%22categoryId%22%3a5%2c%22deviceId%22%3a%22000c9b8e74010000000054c415b9c1a4%22%7d";
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionUrl]];
注：url的content参数用json形式包装，且做了UTF-8 encode，避免特殊字符影响解析。

调用QMAction，参数从url中获取
QMAction *action = [QMAction actionFromUrl:@"beehome://device?type=0&content=%7b%22categoryId%22%3a5%2c%22deviceId%22%3a%22000c9b8e74010000000054c415b9c1a4%22%7d"];
[[QMActionManager sharedManager] performAction:action];

调用QMAction，参数从字典或content字符串中获取
QMAction *action = [QMAction actionWithType:0 module:ACTION_MODULE_DEVICE contentDict:@{@"categoryId":@(5),@"deviceId":@"22000c9b8e74010000000054c415b9c1a4"} jumpController:self.navigationController];
[[QMActionManager sharedManager] performAction:action];

QMAction *action = [QMAction actionWithType:0 module:ACTION_MODULE_DEVICE content:@"%7b%22categoryId%22%3a5%2c%22deviceId%22%3a%22000c9b8e74010000000054c415b9c1a4%22%7d" jumpController:self.navigationController];
[[QMActionManager sharedManager] performAction:action];

调用QMAction， 执行带有成功和失败的回调block的方法
QMAction *action = [QMAction actionFromUrl:url.absoluteString jumpController:jumpController];
if ([[QMActionManager sharedManager] findClassForAction:action]) {
[[QMActionManager sharedManager] performAction:action withSuccess:^(id target) {
if (target) {
QMAction *nextAction = [QMAction actionFromUrl:action.succUrl jumpController:jumpController];
if (nextAction) {
[[QMActionManager sharedManager] performAction:nextAction];
}

}
} failed:^(QMActionErrorCode errorCode) {
SHLogInfo(kLogModuleCommon,@"error:%d, url:%@",(long)errorCode,url.absoluteString);
}];
return YES;
}
注：失败回调包括找不到class、action参数不正确、业务类定义的失败等。由调用方根据errorCode自行处理。
