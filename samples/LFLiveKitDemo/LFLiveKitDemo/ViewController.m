//
//  ViewController.m
//  LFLiveKitDemo
//
//  Created by admin on 16/8/30.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>
#import <LFLiveKit.h>
#import "AppDelegate.h"

inline static NSString *formatedSpeed(float bytes, float elapsed_milli) {
    if (elapsed_milli <= 0) {
        return @"N/A";
    }
    if (bytes <= 0) {
        return @"0 KB/s";
    }
    float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
    if (bytes_per_sec >= 1000 * 1000) {
        return [NSString stringWithFormat:@"%.2f MB/s", ((float)bytes_per_sec) / 1000 / 1000];
    } else if (bytes_per_sec >= 1000) {
        return [NSString stringWithFormat:@"%.1f KB/s", ((float)bytes_per_sec) / 1000];
    } else {
        return [NSString stringWithFormat:@"%ld B/s", (long)bytes_per_sec];
    }
}


@interface ViewController () <LFLiveSessionDelegate, RPBroadcastControllerDelegate, RPBroadcastActivityViewControllerDelegate>
@property (nonatomic, strong) LFLiveSession *session;
@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) RPBroadcastController *broadcastController;
@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://www.baidu.com"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 请求网络权限
    }] resume];
    
    UIView *testView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        [view setBackgroundColor:[UIColor purpleColor]];
        view;
    });
    [self.view addSubview:testView];
    
    {
        /*
         这个动画会让直播一直有视频帧
         动画类型不限，只要屏幕是变化的就会有视频帧
         */
        [testView.layer removeAllAnimations];
        CABasicAnimation *rA = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rA.duration = 3.0;
        rA.toValue = [NSNumber numberWithFloat:M_PI * 2];
        rA.repeatCount = MAXFLOAT;
        rA.removedOnCompletion = NO;
        [testView.layer addAnimation:rA forKey:@""];
    }
    
    UIButton *perpareButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(50, 300, 100, 50)];
        [button setTitle:@"Perpare" forState:UIControlStateNormal];
        // 连接直播端口 < 准备直播
        [button addTarget:self action:@selector(perpare) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    UIButton *statrButton1 = ({
        // 第一种直播方式
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(130, 300, 100, 50)];
        [button setTitle:@"Start" forState:UIControlStateNormal];
        // 点击开始推流
        [button addTarget:self action:@selector(statrButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    UIButton *statrButton2 = ({
        // 第二种直播方式 调用Extension
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(300, 300, 150, 50)];
        [button setTitle:@"Extension" forState:UIControlStateNormal];
        // 点击开始推流
        [button addTarget:self action:@selector(startLive) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [self.view addSubview:perpareButton];
    [self.view addSubview:statrButton1];
    [self.view addSubview:statrButton2];
    
}

#pragma mark -- Getter Setter
- (LFLiveSession *)session {
    if (_session == nil) {
        
        LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQuality_High];
        audioConfiguration.numberOfChannels = 1;
        LFLiveVideoConfiguration *videoConfiguration;
        
        videoConfiguration = [LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_High2 outputImageOrientation:UIInterfaceOrientationLandscapeRight];
        
        videoConfiguration.autorotate = YES;
        
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration captureType:LFLiveInputMaskAll];
        
        _session.delegate = self;
        _session.showDebugInfo = YES;
        
    }
    return _session;
}


- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    switch (state) {
        case LFLiveReady:
            NSLog(@"未连接");
            break;
        case LFLivePending:
            NSLog(@"连接中");
            break;
        case LFLiveStart:
            NSLog(@"已连接");
            break;
        case LFLiveError:
            NSLog(@"连接错误");
            break;
        case LFLiveStop:
            NSLog(@"未连接");
            break;
        default:
            break;
    }
}

- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo {
    NSString *speed = formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli);
    NSLog(@"speed:%@", speed);
}

- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
    NSLog(@"errorCode: %lu", (unsigned long)errorCode);
}


- (void)perpare {
    LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
    // /直播推流地址
    stream.url = @"rtmp://send3a.douyu.com/live/3523327rRE27GZhP?wsSecret=0498fe929f8783d5f42fb660c23de61a&wsTime=5c08e4bf&wsSeek=off&wm=0&tw=0";
    
    [self.session startLive:stream];
    
    
    [[RPScreenRecorder sharedRecorder] setMicrophoneEnabled:YES];
}

- (void)statrButtonClick:(UIButton *)sender {
    if ([[RPScreenRecorder sharedRecorder] isRecording]) {
        NSLog(@"Recording, stop record");
        if (@available(iOS 11.0, *)) {
            [self.session stopLive];
            [[RPScreenRecorder sharedRecorder] stopCaptureWithHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"stopCaptureWithHandler:%@", error.localizedDescription);
                } else {
                    NSLog(@"CaptureWithHandlerStoped");
                }
            }];
        } else {
            // Fallback on earlier versions
        }
    } else {
        if (@available(iOS 11.0, *)) {
            NSLog(@"start Recording");
            [[RPScreenRecorder sharedRecorder] startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
//                NSLog(@"bufferTyped:%ld", (long)bufferType);
                switch (bufferType) {
                    case RPSampleBufferTypeVideo:
                        [self.session pushVideoBuffer:sampleBuffer];
                        break;
                    case RPSampleBufferTypeAudioMic:
                        [self.session pushAudioBuffer:sampleBuffer];
                        break;
                        
                    default:
                        break;
                }
                if (error) {
                    NSLog(@"startCaptureWithHandler:error:%@", error.localizedDescription);
                }
            } completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"completionHandler:error:%@", error.localizedDescription);
                }
            }];
        } else {
            // Fallback on earlier versions
        }
        
    }
}



#pragma mark -
#pragma mark Extension

- (void)startLive {
// 如果需要mic，需要打开x此项
    [[RPScreenRecorder sharedRecorder] setMicrophoneEnabled:YES];
    
    if (![RPScreenRecorder sharedRecorder].isRecording) {
        [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
            if (error) {
                NSLog(@"RPBroadcast err %@", [error localizedDescription]);
            }
            broadcastActivityViewController.delegate = self;
            broadcastActivityViewController.modalPresentationStyle = UIModalPresentationPopover;
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                broadcastActivityViewController.popoverPresentationController.sourceRect = self.testView.frame;
                broadcastActivityViewController.popoverPresentationController.sourceView = self.testView;
            }
            [self presentViewController:broadcastActivityViewController animated:YES completion:nil];
        }];
    } else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop Live?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes",nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self stopLive];
        }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:ok];
        [alert addAction:cancle];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}
- (void)stopLive {
    [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"finishBroadcastWithHandler:%@", error.localizedDescription);
        }
        
    }];
}

#pragma mark - Broadcasting
- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *) broadcastActivityViewController
       didFinishWithBroadcastController:(RPBroadcastController *)broadcastController
                                  error:(NSError *)error {
    
    [broadcastActivityViewController dismissViewControllerAnimated:YES
                                                        completion:nil];
    NSLog(@"BundleID %@", broadcastController.broadcastExtensionBundleID);
    self.broadcastController = broadcastController;
    self.broadcastController.delegate = self;
    if (error) {
        NSLog(@"BAC: %@ didFinishWBC: %@, err: %@",
              broadcastActivityViewController,
              broadcastController,
              error);
        return;
    }

    [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"-----start success----");
            // 这里可以添加camerPreview
        } else {
            NSLog(@"startBroadcast:%@",error.localizedDescription);
        }
    }];
    
}


// Watch for service info from broadcast service
- (void)broadcastController:(RPBroadcastController *)broadcastController
       didUpdateServiceInfo:(NSDictionary <NSString *, NSObject <NSCoding> *> *)serviceInfo {
    NSLog(@"didUpdateServiceInfo: %@", serviceInfo);
    
    
}

// Broadcast service encountered an error
- (void)broadcastController:(RPBroadcastController *)broadcastController
         didFinishWithError:(NSError *)error {
    NSLog(@"didFinishWithError: %@", error);
}

- (void)broadcastController:(RPBroadcastController *)broadcastController didUpdateBroadcastURL:(NSURL *)broadcastURL {
    NSLog(@"---didUpdateBroadcastURL: %@",broadcastURL);
}

@end
