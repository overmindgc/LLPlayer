//
//  AudioRecordControlView.h
//  LLPlayer
//
//  Created by 辰 宫 on 14/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LL_AUDIO_CONTROL_START_RECORD @"LLAudioControlStartRecord" //开始录音事件
#define LL_AUDIO_CONTROL_END_RECORD @"LLAudioControlEndRecord" //结束录音事件

#define LL_AUDIO_CONTROL_START_PLAY_MYSELF @"LLAudioControlStartPlayMySelf" //开始播放自己声音
#define LL_AUDIO_CONTROL_END_PLAY_MYSELF @"LLAudioControlEndPlayMySelf" //结束播放自己声音

@interface AudioRecordControlView : UIView

@end
