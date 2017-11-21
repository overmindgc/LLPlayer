//
//  AudioRecordClient.m
//  LLPlayer
//
//  Created by 辰 宫 on 13/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "AudioRecordClient.h"
#import <AVFoundation/AVFoundation.h>

@implementation AudioRecordClient

+ (AudioRecordClient *)defaultClient
{
    static dispatch_once_t once;
    static AudioRecordClient *sharedInstance = nil;
    dispatch_once(&once, ^
                  {
                      sharedInstance = [[self alloc] init];
                  });
    
    return sharedInstance;
}

/**
 *  设置音频会话
 */
- (void)setAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    //AVAudioSessionCategoryPlayAndRecord用于录音和播放,使用AVAudioSessionCategoryOptionDefaultToSpeaker默认开启扬声器，不然可能听筒
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&sessionError];
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
}

////听筒模式
//- (void)setRecordAudioSession
//{
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    NSError *sessionError;
//
//    [session setCategory:AVAudioSessionCategoryRecord error:&sessionError];
//    if(session == nil)
//        NSLog(@"Error creating session: %@", [sessionError description]);
//    else
//        [session setActive:YES error:nil];
//}
////扬声器模式
//- (void)setPlayerAudioSession
//{
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    NSError *sessionError;
//
//    [session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
//    if(session == nil)
//        NSLog(@"Error creating session: %@", [sessionError description]);
//    else
//        [session setActive:YES error:nil];
//}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *)audioRecordingSettings {
    
    NSDictionary *result = nil;
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    //    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    result = [NSDictionary dictionaryWithDictionary:recordSetting];
    return result;
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
- (NSURL *)getSavePath {
    
    //  在Documents目录下创建一个名为FileData的文件夹
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:RecordAudioCacheFolder];
    NSLog(@"%@",path);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir)) {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
        NSLog(@"创建文件夹成功，文件路径%@",path);
    }
    
    path = [path stringByAppendingPathComponent:RecordAudioFileName];
    NSLog(@"file path:%@",path);
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
}


@end
