//
//  ZFUploadTool.h
//  Recoder
//
//  Created by 张帆 on 2018/12/6.
//  Copyright © 2018 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZFUploadTool : NSObject

+ (instancetype)shareTool;
- (void)prepareToStart:(NSDictionary *)dict;

- (void)stop;
- (void)sendAudioBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)sendVideoBuffer:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
