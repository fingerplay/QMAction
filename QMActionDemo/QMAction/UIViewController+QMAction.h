//
//  UIViewController+QMAction.h
//  QMActionDemo
//
//  Created by 罗谨 on 2017/7/4.
//  Copyright © 2017年 juanpi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMAction.h"

@interface UIViewController (QMAction)
- (BOOL)shouldCreateVCWithAction:(QMAction *)action andClass:(__unsafe_unretained Class)cls;

@end


