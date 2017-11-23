//
//  AVUtils.m
//  LLPlayer
//
//  Created by 辰 宫 on 06/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "AVUtils.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation AVUtils

+ (UIImage *)getVideoThumbImage:(AVURLAsset *)asset
{
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    NSLog(@"%@",asset);
    if (asset) {
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        
        gen.appliesPreferredTrackTransform = YES;
        
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        
        NSError *error = nil;
        
        CMTime actualTime;
        
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        
        CGImageRelease(image);
        
        return thumb;
    } else {
        return nil;
    }
}

+ (NSString *)getVideoTotalTime:(AVURLAsset *)asset
{
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    if (asset) {
        Float64 duration = CMTimeGetSeconds(asset.duration);
        NSString *strTime=[self convertSecondToTime:duration];
        return strTime;
    } else {
        return nil;
    }
}

//将数值转换成时间
+ (NSString *)convertSecondToTime:(CGFloat)second
{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

+ (CGSize)getVideoSize:(AVURLAsset *)asset
{
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    if (asset) {
        NSArray *array = asset.tracks;
        CGSize videoSize = CGSizeZero;
        for (AVAssetTrack *track in array) {
            if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
                videoSize = track.naturalSize;
            }
        }
        return videoSize;
    } else {
        return CGSizeZero;
    }
}

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
{
    if (!videoPath) {
        return;
    }
    //1 创建AVAsset实例 AVAsset包含了video的所有信息 self.videoUrl输入视频的路径
    [SVProgressHUD showWithStatus:@"正在保存视频"];
    //封面图片
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(YES) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];

    AVAsset * videoAsset = [AVURLAsset URLAssetWithURL:videoPath options:opts];     //初始化视频媒体文件
    
    //开始时间
    CMTime startCropTime = CMTimeMakeWithSeconds(startTime, 600);
    //结束时间
    CMTime endCropTime = CMTimeMakeWithSeconds(endTime, 600);
    if (endTime == 0) {
        endCropTime = CMTimeMakeWithSeconds(videoAsset.duration.value/videoAsset.duration.timescale-startTime, videoAsset.duration.timescale);
    }
    
    //2 创建AVMutableComposition实例. apple developer 里边的解释 【AVMutableComposition is a mutable subclass of AVComposition you use when you want to create a new composition from existing assets. You can add and remove tracks, and you can add, remove, and scale time ranges.】
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    //有声音并且不需要合成配音
    if ([[videoAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0 && !musicPath){
        //声音采集
        AVURLAsset * audioAsset = [[AVURLAsset alloc] initWithURL:videoPath options:opts];
        //音频通道
        AVMutableCompositionTrack * audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        //音频采集通道
        AVAssetTrack * audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] lastObject];
        [audioTrack insertTimeRange:CMTimeRangeFromTimeToTime(startCropTime, endCropTime) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    }
    
    //3 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError *error;
    //把视频轨道数据加入到可变轨道中 这部分可以做视频裁剪TimeRange
    [videoTrack insertTimeRange:CMTimeRangeFromTimeToTime(startCropTime, endCropTime)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] lastObject]
                         atTime:kCMTimeZero error:&error];
    
    //加入录音音轨
    AVMutableAudioMix *videoAudioMixTools;
    //replace music
    if (musicPath) {
        AVAsset *musicAsset = [AVAsset assetWithURL:musicPath];
        if (musicAsset) {
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                     preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioTrack insertTimeRange:CMTimeRangeFromTimeToTime(kCMTimeZero, videoAsset.duration)
                                ofTrack:[[musicAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];

            videoAudioMixTools = [AVMutableAudioMix audioMix];
            //调节音量
            //获取音频轨道
            AVMutableAudioMixInputParameters *firstAudioParam = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
            //设置音轨音量,可以设置渐变,设置为1.0就是全音量
            [firstAudioParam setVolumeRampFromStartVolume:1.0 toEndVolume:1.0 timeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)];
            [firstAudioParam setTrackID:audioTrack.trackID];
            videoAudioMixTools.inputParameters = [NSArray arrayWithObject:firstAudioParam];
        }
    }
    
    
    // 4 - 输出路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *createFolderPath = [NSString stringWithFormat:@"%@/%@",documentsDirectory,DubbingVideoFolder];
    if (![[NSFileManager defaultManager] fileExistsAtPath:createFolderPath])//判断createPath路径文件夹是否已存在
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:createFolderPath withIntermediateDirectories:YES attributes:nil error:nil];//创建文件夹
    }
    NSString *myPathDocs =  [createFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",fileName]];
    unlink([myPathDocs UTF8String]);
    NSURL* videoUrl = [NSURL fileURLWithPath:myPathDocs];

    // 5 - 视频文件输出
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = videoUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.audioMix = videoAudioMixTools;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //这里是输出视频之后的操作，做你想做的
//            [self cropExportDidFinish:exporter];
            [SVProgressHUD dismiss];
        });
    }];
}

@end
