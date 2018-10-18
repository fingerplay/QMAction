//
//  ViewController.m
//  QMActionDemo
//
//  Created by 罗谨 on 2017/7/4.
//  Copyright © 2017年 juanpi. All rights reserved.
//

#import "ViewController.h"
#import "QMActionManager.h"
#import "QMJSONManager.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *jumpBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Demo";
    [self.view addSubview:self.jumpBtn];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)jumpBtnClick:(id)sender {
    NSString *param = [QMJSONManager JSONStringFromObject:@{@"url":@"https://m.juanpi.com"}];
    QMAction *action = [QMAction actionWithType:QMActionTypeDefaultWebVC content:param jumpController:self.navigationController];
    [[QMActionManager sharedManager] performAction:action];
    
}

- (UIButton *)jumpBtn {
    if (!_jumpBtn) {
        _jumpBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        _jumpBtn.center = CGPointMake(self.view.bounds.size.width/2, 100);
        [_jumpBtn addTarget:self action:@selector(jumpBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_jumpBtn setTitle:@"点击跳转" forState:UIControlStateNormal];
        [_jumpBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    return _jumpBtn;
}


@end
