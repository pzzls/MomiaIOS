//
//  AppDelegate.h
//  MomiaIOS
//
//  Created by Deng Jun on 15/4/16.
//  Copyright (c) 2015年 Deng Jun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeTuiSdk.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import "WechatPayDelegate.h"
#import "MORootViewController.h"
#import "WechatPayData.h"
#import "PushManager.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, GeTuiSdkDelegate, WXApiDelegate, WeiboSDKDelegate, WechatPayDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setTitleShadow:(UIImage *)image aboveSubview:(UIView *)view;

@property (strong, nonatomic) MORootViewController *root;

@property (retain, nonatomic) NSString *appKey;
@property (retain, nonatomic) NSString *appSecret;
@property (retain, nonatomic) NSString *appID;
@property (retain, nonatomic) NSString *clientId;
@property (assign, nonatomic) SdkStatus sdkStatus;

@property (nonatomic, strong) NSMutableDictionary *imUserDic;
@property (nonatomic, strong) NSMutableDictionary *imGroupDic;

@end

