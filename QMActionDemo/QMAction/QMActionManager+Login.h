//
//  QMActionManager+Login.h
//  juanpi3
//
//  Created by 罗谨 on 2017/8/9.
//  Copyright © 2017年 罗谨. All rights reserved.
//

#import "QMActionManager.h"

@interface QMActionManager (Login)

- (BOOL)shouldPerformLoginBeforeAction:(QMAction *)action;

- (void)performAction:(QMAction *)action afterLogin:(void (^)())completion;

@end
