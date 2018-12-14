//
//  BroadcastSetupViewController.m
//  RecoderSetupUI
//
//  Created by 张帆 on 2018/12/6.
//  Copyright © 2018 admin. All rights reserved.
//

#import "BroadcastSetupViewController.h"

@implementation BroadcastSetupViewController

- (void)viewDidLoad {
    
    
    /*
        在这个界面用来是配置直播参数
     */
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *startBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(100, 100, 100, 100)];
        [button setBackgroundColor:[UIColor purpleColor]];
        [button setTitle:@"Start" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(userDidFinishSetup) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    UIButton *closeBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(230, 100, 100, 100)];
        [button setBackgroundColor:[UIColor redColor]];
        [button setTitle:@"Close" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(userDidCancelSetup) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [self.view addSubview:startBtn];
    [self.view addSubview:closeBtn];
    
   
    
}


// Call this method when the user has finished interacting with the view controller and a broadcast stream can start
- (void)userDidFinishSetup {
    
    // URL of the resource where broadcast can be viewed that will be returned to the application
    NSURL *broadcastURL = [NSURL URLWithString:@"http://apple.com/broadcast/streamID"];
    
    // 所有需要的信息都可以通过setupInfo传递到Extension 的 SampleHandler里
    NSDictionary *setupInfo = @{ @"broadcastName" : @"example" };
    
    // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
    [self.extensionContext completeRequestWithBroadcastURL:broadcastURL setupInfo:setupInfo];
}

- (void)userDidCancelSetup {
    // Tell ReplayKit that the extension was cancelled by the user
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"YourAppDomain" code:-1 userInfo:nil]];
}

@end
