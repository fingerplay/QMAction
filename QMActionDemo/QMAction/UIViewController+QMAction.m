//
//  UIViewController+QMAction.m
//  QMActionDemo
//
//  Created by 罗谨 on 2017/7/4.
//  Copyright © 2017年 juanpi. All rights reserved.
//

#import "UIViewController+QMAction.h"

@implementation UIViewController (QMAction)


- (BOOL)shouldCreateVCWithAction:(QMAction *)action andClass:(__unsafe_unretained Class)cls{
    return YES;
}
@end
