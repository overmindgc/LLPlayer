//
//  TimeUtils.m
//  LLPlayer
//
//  Created by 辰 宫 on 20/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "TimeUtils.h"

@implementation TimeUtils

+ (NSString *)getMMSSFromSS:(NSInteger)seconds
{
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    
    return format_time;
}

+ (NSString *)getHHMMSSFromSS:(NSInteger)seconds
{
    //format of minute
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time;
    if ([str_hour integerValue] > 0) {
        format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    } else {
        format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    return format_time;
}

@end
