//
//  AVUtils.h
//  LLPlayer
//
//  Created by 辰 宫 on 06/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AVUtils : NSObject

+ (UIImage *)getVideoThumbImage:(AVURLAsset *)asset;

+ (NSString *)getVideoTotalTime:(AVURLAsset *)asset;

//将数值转换成时间
+ (NSString *)convertSecondToTime:(CGFloat)second;

+ (CGSize)getVideoSize:(AVURLAsset *)asset;

/**
 裁剪视频
 @param videoPath 视频的路径
 @param startTime 截取视频开始时间
 @param endTime 截取视频结束时间，如果为0则为整个视频
 @param fileName 文件名字
 @param musicPath 是否需要替换背景音乐
 */
+ (void)goSaveVideoPath:(NSURL*)videoPath
          withStartTime:(float)startTime
            withEndTime:(float)endTime
           withFileName:(NSString*)fileName
         replaceByMusic:(NSURL *)musicPath
;

@end
