//
//  AVUtils.m
//  LLPlayer
//
//  Created by 辰 宫 on 06/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "AVUtils.h"

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
 @param videoSize 视频截取的大小，如果为0则不裁剪视频大小
 @param videoDealPoint Point(x,y):传zero则为裁剪从0,0开始
 @param fileName 文件名字
 @param shouldScale 是否拉伸，false的话不拉伸，裁剪黑背景
 @param musicPath 是否需要替换背景音乐
 */
+ (void)goSaveVideoPath:(NSURL*)videoPath
          withStartTime:(float)startTime
            withEndTime:(float)endTime
               withSize:(CGSize)videoSize
     withVideoDealPoint:(CGPoint)videoDealPoint
           withFileName:(NSString*)fileName
            shouldScale:(BOOL)shouldScale
 isWxVideoAssetvertical:(BOOL)Assetvertical
         replaceByMusic:(NSURL *)musicPath
{
    if (!videoPath) {
        return;
    }
    //1 创建AVAsset实例 AVAsset包含了video的所有信息 self.videoUrl输入视频的路径
    
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
    
    //有声音
    if ([[videoAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0){
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
    
    
    //3.1 AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeFromTimeToTime(kCMTimeZero, videoTrack.timeRange.duration);
    
    // 3.2 AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    //拍摄的时候视频是否是竖屏拍的
    BOOL isVideoAssetvertical  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        isVideoAssetvertical = YES;
        videoAssetOrientation_ =  UIImageOrientationUp;//正着拍
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        //        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetvertical = YES;
        videoAssetOrientation_ = UIImageOrientationDown;//倒着拍
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        isVideoAssetvertical = NO;
        videoAssetOrientation_ =  UIImageOrientationLeft;//左边拍的
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        isVideoAssetvertical = NO;
        videoAssetOrientation_ = UIImageOrientationRight;//右边拍
    }
    
    float scaleX = 1.0,scaleY = 1.0,scale = 1.0;
    CGSize originVideoSize;
    if (isVideoAssetvertical || Assetvertical) {
        originVideoSize = CGSizeMake([[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].height, [[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width);
    }
    else{
        originVideoSize = CGSizeMake([[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width, [[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].height);
    }
    float x = videoDealPoint.x;
    float y = videoDealPoint.y;
    if (shouldScale) {
        scaleX = videoSize.width/originVideoSize.width;
        scaleY = videoSize.height/originVideoSize.height;
        scale  = MAX(scaleX, scaleY);
        if (scaleX>scaleY) {
            NSLog(@"竖屏");
        }
        else{
            NSLog(@"横屏");
        }
    }
    else{
        scaleX = 1.0;
        scaleY = 1.0;
        scale = 1.0;
    }
    if (Assetvertical) {
        CGAffineTransform trans = CGAffineTransformMake(videoAssetTrack.preferredTransform.a*scale, videoAssetTrack.preferredTransform.b*scale, videoAssetTrack.preferredTransform.c*scale, videoAssetTrack.preferredTransform.d*scale, videoAssetTrack.preferredTransform.tx*scale-x+720, videoAssetTrack.preferredTransform.ty*scale-y);
        
        //    [videolayerInstruction setTransform:trans atTime:kCMTimeZero];
        CGAffineTransform trans2 = CGAffineTransformRotate(trans, M_PI_2);
        [videolayerInstruction setTransform:trans2 atTime:kCMTimeZero];
    }
    else{
        CGAffineTransform trans = CGAffineTransformMake(videoAssetTrack.preferredTransform.a*scale, videoAssetTrack.preferredTransform.b*scale, videoAssetTrack.preferredTransform.c*scale, videoAssetTrack.preferredTransform.d*scale, videoAssetTrack.preferredTransform.tx*scale-x, videoAssetTrack.preferredTransform.ty*scale-y);
        
        [videolayerInstruction setTransform:trans atTime:kCMTimeZero];
    }
    //裁剪区域
    //    [videolayerInstruction setCropRectangle:CGRectMake(0, 0, 720, 720) atTime:kCMTimeZero];
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    //AVMutableVideoComposition：管理所有视频轨道，可以决定最终视频的尺寸，裁剪需要在这里进行
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;

    naturalSize = originVideoSize;
    int64_t renderWidth = 0, renderHeight = 0;
    if (videoSize.height ==0.0 || videoSize.width == 0.0) {
        renderWidth = naturalSize.width;
        renderHeight = naturalSize.height;
    }
    else{
        renderWidth = ceil(videoSize.width);
        renderHeight = ceil(videoSize.height);
    }
    
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    //replace music
//    if (musicPath) {
//        AVAsset *musicAsset = [AVAsset assetWithURL:musicPath];
//        if (musicAsset) {
//            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
//                                                     preferredTrackID:kCMPersistentTrackID_Invalid];
//            [audioTrack insertTimeRange:CMTimeRangeFromTimeToTime(kCMTimeZero, CMTimeAdd(videoAsset.duration, videoAsset.duration))
//                                ofTrack:[[musicAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
//        }
//    }
    
    // 4 - 输出路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",fileName]];
    unlink([myPathDocs UTF8String]);
    NSURL* videoUrl = [NSURL fileURLWithPath:myPathDocs];

    // 5 - 视频文件输出
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=videoUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //这里是输出视频之后的操作，做你想做的
//            [self cropExportDidFinish:exporter];
        });
    }];
}

@end
