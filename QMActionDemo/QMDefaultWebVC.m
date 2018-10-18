//
//  QMDefaultWebVC.m
//  Jiukuaiyou_2.0
//
//  Created by Brick on 14-4-1.
//  Copyright (c) 2014年 QM. All rights reserved.
//

#import "QMDefaultWebVC.h"
#import "QMActionManager.h"
#import "UIView+Extension.h"

@interface QMDefaultWebVC() <QMActionProtocol,UIWebViewDelegate>
/**
 *  左边按钮
 */
@property (nonatomic, strong) UIView *leftItemView;

/**
 *  右边按钮
 */
@property (nonatomic, strong) UIView *rightItemView;
@end


@implementation QMDefaultWebVC
#pragma mark - LifeCycle

- (void)dealloc
{

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.showWebView];
    UIButton *buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(-15, 0, 44, 44)];
    [buttonLeft setTitle:@"左边" forState:UIControlStateNormal];
    [buttonLeft setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addLeftItemView:buttonLeft];
    
    UIButton *buttonRight = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 44, 44)];
    [buttonRight setTitle:@"右边" forState:UIControlStateNormal];
    [buttonRight setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [buttonRight addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addRightItemView:buttonRight];
    
    [self webViewRequest:self.urlString];
}


- (void)leftBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addLeftItemView:(UIView *)leftView{
    if (leftView) {
        [self.leftItemView setFrame:leftView.frame];
        [self.leftItemView addSubview:leftView];
        [self.leftItemView setNeedsLayout];
        [self adjustTitleFrame];
        UIBarButtonItem *itemBar = [[UIBarButtonItem alloc] initWithCustomView:self.leftItemView];
        self.navigationItem.leftBarButtonItem = itemBar;
    }
}

- (void)addRightItemView:(UIView *)rightView{
    if (rightView) {
        [self.rightItemView addSubview:rightView];
        [self.rightItemView setFrame:rightView.frame];
        [self.rightItemView setNeedsLayout];
        [self adjustTitleFrame];
        UIBarButtonItem *itemBarB = [[UIBarButtonItem alloc] initWithCustomView:self.rightItemView];
        self.navigationItem.rightBarButtonItem = itemBarB;
    }
}

- (void)adjustTitleFrame {
    if (self.rightItemView.bounds.size.width > self.leftItemView.bounds.size.width) {
        CGRect frame = self.leftItemView.frame;
        frame.size.width = self.rightItemView.bounds.size.width;
        self.leftItemView.frame = frame;
//        self.leftItemView.width  = self.rightItemView.width;
        [self.leftItemView setNeedsLayout];
    } else if(self.rightItemView.bounds.size.width< self.leftItemView.bounds.size.width){
        CGRect frame = self.rightItemView.frame;
        frame.size.width = self.leftItemView.bounds.size.width;
        self.rightItemView.frame = frame;
//        self.rightItemView.width = self.leftItemView.width;
        [self.rightItemView setNeedsLayout];
    }
    
}

-(void)webGo:(NSString*)urlString
{
    if (!urlString) {
        return;
    }
    
    self.urlString = urlString;
    
    if (_showWebView) {//如果页面已加载，则开始请求
        [self webViewRequest:self.urlString];
    }
}


- (void)webViewRequest:(NSString *)urlString {
    if (!urlString.length) {
        return ;
    }

    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        request.timeoutInterval = 30;
        [self.showWebView loadRequest:request];
    }
    
}


-(BOOL)handleWebAPI:(NSString*)url
{
    NSString *urlString = url;
    if (!url) {
        return NO;
    }
    
    if ([urlString rangeOfString:QIMI_SCHEME].location!=NSNotFound){
        [self handleQimiAction:urlString];
        return NO;
    }
    
    return YES;
}

- (void)handleQimiAction:(NSString *)urlString {
    //新的跳转逻辑，跳转页面在此方法里面执行
    QMAction *action = [QMAction actionFromUrl:urlString jumpController:self.navigationController];

    action.sourceType = QMActionSourceTypeWebView;
    [[QMActionManager sharedManager] performAction:action];
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if (![self handleWebAPI:request.URL.absoluteString]) {
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *str = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = str;
}


#pragma mark - QMActionProtocol
+ (BOOL)canHandleAction:(QMAction *)action {
    if (action.type== QMActionTypeDefaultWebVC) {
        return YES;
    }
    
    return NO;
}

+ (id)createViewControllerWithAction:(QMAction *)action {
    NSInteger type = action.type;
  
    if (type != QMActionTypeDefaultWebVC) {
        return nil;
    }
    
    NSString *content = action.content;
    NSDictionary *dict = [QMJSONManager objectFromJSONString:content];
    NSString *url = [dict objectForKey:@"url"];

    QMDefaultWebVC *web = [[QMDefaultWebVC alloc] init];
    if ([url isKindOfClass:[NSString class]] &&  url.length) {
        [web webGo:url];
    }
    return web;
}





#pragma mark - property

- (UIView *)leftItemView{
    if (_leftItemView) {
        return _leftItemView;
    }
    _leftItemView = [[UIView alloc] initWithFrame:CGRectZero];
//    _leftItemView.backgroundColor = [UIColor redColor];
    return _leftItemView;
}

- (UIView *)rightItemView{
    if (_rightItemView) {
        return _rightItemView;
    }
    _rightItemView = [[UIView alloc] initWithFrame:CGRectZero];
//    _rightItemView.backgroundColor = [UIColor redColor];
    return _rightItemView;
}

- (UIWebView *)showWebView
{
    if (_showWebView) {
        return _showWebView;
    }
    
    _showWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _showWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _showWebView.opaque = NO;
    _showWebView.backgroundColor = [UIColor whiteColor];
    _showWebView.delegate = self;
    return _showWebView;
}

@end
