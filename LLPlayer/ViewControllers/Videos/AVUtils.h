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

@end
