//
//  TimeUtils.h
//  LLPlayer
//
//  Created by 辰 宫 on 20/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeUtils : UIView

/**
 * 根据秒数返回00:00格式
 */
+ (NSString *)getMMSSFromSS:(NSInteger)seconds;

/**
 * 根据秒数返回00:00:00格式
 */
+ (NSString *)getHHMMSSFromSS:(NSInteger)seconds;

@end
