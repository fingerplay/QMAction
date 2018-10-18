//
//  QMDefaultWebVC.h
//  Jiukuaiyou_2.0
//
//  Created by Brick on 14-4-1.
//  Copyright (c) 2014年 QM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMDefaultWebVC : UIViewController

@property (nonatomic, strong) UIWebView *showWebView;

@property (nonatomic, copy) NSString *urlString;

/**
 *  设置请求地址
 *
 *  @param urlString 网页请求地址
 */
-(void)webGo:(NSString*)urlString;

@end
