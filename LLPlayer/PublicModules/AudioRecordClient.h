//
//  AudioRecordClient.h
//  LLPlayer
//
//  Created by 辰 宫 on 13/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioRecordClient : NSObject

+ (AudioRecordClient *)defaultClient;

/**
 *  设置音频会话
 */
- (void)setAudioSession;
//- (void)setRecordAudioSession;
//- (void)setPlayerAudioSession;

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *)audioRecordingSettings;

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
- (NSURL *)getSavePath;

@end
