//
//  SampleHandler.m
//  Recoder
//
//  Created by 张帆 on 2018/12/6.
//  Copyright © 2018 admin. All rights reserved.
//


#import "SampleHandler.h"
#import "ZFUploadTool.h"

@interface SampleHandler ()

@property (nonatomic, strong) ZFUploadTool *tool;
@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    [self requireNetwork];
    self.tool = [ZFUploadTool shareTool];
    [self.tool prepareToStart:setupInfo];
    NSLog(@"------prepareToStart-------");
    
}

- (void)broadcastPaused {
    
}

- (void)broadcastResumed {

}

- (void)broadcastFinished {
    [self.tool stop];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            [self.tool sendVideoBuffer:sampleBuffer];
            break;
        case RPSampleBufferTypeAudioApp:
            //            [self.tool sendAudioBuffer:sampleBuffer];
            break;
        case RPSampleBufferTypeAudioMic:
            [self.tool sendAudioBuffer:sampleBuffer];
            break;
            
        default:
            break;
    }
}

- (void)requireNetwork {
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://www.baidu.com"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }] resume];
}

@end
