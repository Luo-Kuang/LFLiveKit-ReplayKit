//
//  LFLiveSession.h
//  LFLiveKit
//
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LFLiveStreamInfo.h"
#import "LFAudioFrame.h"
#import "LFVideoFrame.h"
#import "LFLiveAudioConfiguration.h"
#import "LFLiveVideoConfiguration.h"
#import "LFLiveDebug.h"



typedef NS_ENUM(NSInteger,LFLiveCaptureType) {
    LFLiveInputAudio,           ///< only audio (External input audio)
    LFLiveInputVideo,           ///< only video (External input video)
};


///< 用来控制采集类型（可以内部采集也可以外部传入等各种组合，支持单音频与单视频,外部输入适用于录屏，无人机等外设介入）
typedef NS_ENUM(NSInteger,LFLiveCaptureTypeMask) {
    LFLiveInputMaskAudio = (1 << LFLiveInputAudio),                                     ///< only outer input audio (no video)
    LFLiveInputMaskVideo = (1 << LFLiveInputVideo),                                     ///< only outer input video (no audio)
    LFLiveInputMaskAll = (LFLiveInputMaskAudio | LFLiveInputMaskVideo),                 ///< outer input audio and video(method see pushVideo and pushAudio)
};

@class LFLiveSession;
@protocol LFLiveSessionDelegate <NSObject>

@optional
/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state;
/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo;
/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode;
@end

@class LFLiveStreamInfo;

@interface LFLiveSession : NSObject

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/** The delegate of the capture. captureData callback */
@property (nullable, nonatomic, weak) id<LFLiveSessionDelegate> delegate;

/*  The adaptiveBitrate control auto adjust bitrate. Default is NO */
@property (nonatomic, assign) BOOL adaptiveBitrate;

/** The stream control upload and package*/
@property (nullable, nonatomic, strong, readonly) LFLiveStreamInfo *streamInfo;

/** The status of the stream .*/
@property (nonatomic, assign, readonly) LFLiveState state;

/** The captureType control inner or outer audio and video .*/
@property (nonatomic, assign, readonly) LFLiveCaptureTypeMask captureType;

/** The showDebugInfo control streamInfo and uploadInfo(1s) *.*/
@property (nonatomic, assign) BOOL showDebugInfo;

/** The reconnectInterval control reconnect timeInterval(重连间隔) *.*/
@property (nonatomic, assign) NSUInteger reconnectInterval;

/** The reconnectCount control reconnect count (重连次数) *.*/
@property (nonatomic, assign) NSUInteger reconnectCount;


#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
   The designated initializer. Multiple instances with the same configuration will make the
   capture unstable.
 */
- (nullable instancetype)initWithAudioConfiguration:(nullable LFLiveAudioConfiguration *)audioConfiguration videoConfiguration:(nullable LFLiveVideoConfiguration *)videoConfiguration;

/**
 The designated initializer. Multiple instances with the same configuration will make the
 capture unstable.
 */
- (nullable instancetype)initWithAudioConfiguration:(nullable LFLiveAudioConfiguration *)audioConfiguration videoConfiguration:(nullable LFLiveVideoConfiguration *)videoConfiguration captureType:(LFLiveCaptureTypeMask)captureType NS_DESIGNATED_INITIALIZER;

/** The start stream .*/
- (void)startLive:(nonnull LFLiveStreamInfo *)streamInfo;

/** The stop stream .*/
- (void)stopLive;


- (void)pushVideoBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)pushAudioBuffer:(CMSampleBufferRef)sampleBuffer;

/*
  // support outer input yuv or rgb video(set LFLiveCaptureTypeMask)
- (void)pushVideo:(nullable CVPixelBufferRef)pixelBuffer;

// support outer input pcm audio(set LFLiveCaptureTypeMask)
- (void)pushAudio:(nullable NSData*)audioData;
 */

@end

