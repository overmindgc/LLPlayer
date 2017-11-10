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

@end
