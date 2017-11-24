//
//  AudioRecordControlView.m
//  LLPlayer
//
//  Created by 辰 宫 on 14/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "AudioRecordControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import "SpectrumView.h"
#import "AudioRecordClient.h"
#import "FileHelpers.h"
#import "TimeUtils.h"

@interface AudioRecordControlView () <AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (nonatomic, strong) UILabel *microphoneDescLabel;
@property (nonatomic, strong) UILabel *originDescLabel;
@property (nonatomic, strong) UILabel *myRecordDescLabel;

@property (nonatomic, strong) SpectrumView *spectrumView;
@property (nonatomic, strong) UIView *recordingView;

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *secondTimer;//计秒器
@property (nonatomic) NSInteger currRecordingSecond;

@end

@implementation AudioRecordControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    _microphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_microphoneButton setImage:[UIImage imageNamed:@"record_microphone"] forState:UIControlStateNormal];
    [_microphoneButton addTarget:self action:@selector(micButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _microphoneButton.enabled = NO;
    [self addSubview:_microphoneButton];
    
    _originPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_originPlayButton setImage:[UIImage imageNamed:@"play_origin"] forState:UIControlStateNormal];
    [_originPlayButton setImage:[UIImage imageNamed:@"stop_play"] forState:UIControlStateSelected];
    [_originPlayButton addTarget:self action:@selector(originButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _originPlayButton.enabled = NO;
    [_originPlayButton addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
    [self addSubview:_originPlayButton];
    
    _recordPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_recordPlayButton setImage:[UIImage imageNamed:@"play_myself"] forState:UIControlStateNormal];
    [_recordPlayButton setImage:[UIImage imageNamed:@"stop_play"] forState:UIControlStateSelected];
    _recordPlayButton.enabled = NO;
    [_recordPlayButton addTarget:self action:@selector(myselfButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_recordPlayButton addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
    [self addSubview:_recordPlayButton];
    
    _originDescLabel = [[UILabel alloc] init];
    _originDescLabel.text = @"Origin";
    _originDescLabel.font = [UIFont systemFontOfSize:13];
    _originDescLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_originDescLabel];
    
    _myRecordDescLabel = [[UILabel alloc] init];
    _myRecordDescLabel.text = @"Myself";
    _myRecordDescLabel.font = [UIFont systemFontOfSize:13];
    _myRecordDescLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_myRecordDescLabel];
    
    _saveDubbingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_saveDubbingButton setTitle:@"Save Dubbing" forState:UIControlStateNormal];
    [_saveDubbingButton setTintColor:MainColor];
    _saveDubbingButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _saveDubbingButton.hidden = YES;
    [_saveDubbingButton addTarget:self action:@selector(saveDubbingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveDubbingButton];
    
    _saveClipButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_saveClipButton setTitle:@"Save Clip" forState:UIControlStateNormal];
    [_saveClipButton setTintColor:MainColor];
    _saveClipButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _saveClipButton.hidden = YES;
    [_saveClipButton addTarget:self action:@selector(saveClipButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveClipButton];
    
    _recordingView = [[UIView alloc] init];
    _recordingView.backgroundColor = [UIColor whiteColor];
    _recordingView.hidden = YES;
    [self addSubview:_recordingView];
    
    _spectrumView = [[SpectrumView alloc] init];
    _spectrumView.text = [NSString stringWithFormat:@"%ds",0];
    _spectrumView.middleInterval = 50;
    _spectrumView.itemColor = MainColor_Light;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_spectrumView) weakSpectrumView = _spectrumView;
    _spectrumView.itemLevelCallback = ^{
        [weakSelf.audioRecorder updateMeters];
        //取得第一个通道的音频，音频强度范围是-160到0
        float power = [weakSelf.audioRecorder averagePowerForChannel:0];
        weakSpectrumView.level = power;
    };
    UITapGestureRecognizer *tapGesturRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSpectrumViewAction:)];
    [_spectrumView addGestureRecognizer:tapGesturRecognizer];
    [_recordingView addSubview:_spectrumView];
    
    _microphoneDescLabel = [[UILabel alloc] init];
    _microphoneDescLabel.text = @"Tap to start record";
    _microphoneDescLabel.font = [UIFont systemFontOfSize:14];
    _microphoneDescLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_microphoneDescLabel];
    
    [_microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(60);
    }];
    
    [_originPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_microphoneButton.mas_centerY);
        make.trailing.equalTo(_microphoneButton.mas_leading).offset(-50);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    [_recordPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_microphoneButton.mas_centerY);
        make.leading.equalTo(_microphoneButton.mas_trailing).offset(50);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    [_microphoneDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_microphoneButton.mas_centerX);
        make.bottom.equalTo(_microphoneButton.mas_top).offset(-3);
    }];
    
    [_originDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_originPlayButton.mas_centerX);
        make.top.equalTo(_originPlayButton.mas_bottom).offset(-3);
    }];
    
    [_myRecordDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_recordPlayButton.mas_centerX);
        make.top.equalTo(_recordPlayButton.mas_bottom).offset(-3);
    }];
    
    [_saveClipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_originDescLabel.mas_centerX);
        make.top.equalTo(_originDescLabel.mas_bottom).offset(10);
    }];
    
    [_saveDubbingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_myRecordDescLabel.mas_centerX);
        make.top.equalTo(_myRecordDescLabel.mas_bottom).offset(10);
    }];
    
    [_recordingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(0);
        make.trailing.equalTo(self.mas_trailing).offset(0);
        make.top.equalTo(self.mas_top).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(0);
    }];
    
    CGFloat spectrumPadding = SCREE_WIDTH * 0.1;
    [_spectrumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_recordingView.mas_leading).offset(spectrumPadding);
        make.trailing.equalTo(_recordingView.mas_trailing).offset(-spectrumPadding);
        make.top.equalTo(_recordingView.mas_top).offset(0);
        make.bottom.equalTo(_recordingView.mas_bottom).offset(0);
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (_secondTimer) {
        [self stopSecondTimer];
        _secondTimer = nil;
    }
}

#pragma mark record and play
/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder) {
        [[AudioRecordClient defaultClient] setAudioSession];
        //创建录音文件保存路径
        NSURL *url = [[AudioRecordClient defaultClient] getSavePath];
        //创建录音格式设置
        NSDictionary *setting = [[AudioRecordClient defaultClient] audioRecordingSettings];
        //创建录音机
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        NSURL *url = [[AudioRecordClient defaultClient] getSavePath];
        NSError *error=nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops = 0;
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

/**
 *  @return 定时器
 */
-(NSTimer *)secondTimer{
    if (!_secondTimer) {
        _secondTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(secondTimerChange) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_secondTimer forMode:NSRunLoopCommonModes];
    }
    return _secondTimer;
}

#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"录音完成!");
}

#pragma mark - Player代理
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self playerStopPlay];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    NSLog(@"%@",error);
}

#pragma KVO Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"enabled"]) {
        if (object == self.originPlayButton) {
            NSLog(@"%@",[change valueForKey:NSKeyValueChangeNewKey]);
            self.saveClipButton.hidden = ![[change valueForKey:NSKeyValueChangeNewKey] boolValue];
        } else if (object == self.recordPlayButton) {
            self.saveDubbingButton.hidden = ![[change valueForKey:NSKeyValueChangeNewKey] boolValue];
        }
    }
}

- (void)dealloc
{
    [self.originPlayButton removeObserver:self forKeyPath:@"enabled"];
    [self.recordPlayButton removeObserver:self forKeyPath:@"enabled"];
}

#pragma mark actions
- (void)micButtonClick:(id)sender
{
    [self recordStart];
}

- (void)originButtonClick:(id)sender
{
    UIButton *orgBtn = (UIButton *)sender;
    orgBtn.selected = !orgBtn.selected;

    if (orgBtn.isSelected) {
        [self playerStopPlay];
        [[NSNotificationCenter defaultCenter] postNotificationName:LL_AUDIO_CONTROL_START_PLAY_ORIGIN object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:LL_AUDIO_CONTROL_END_PLAY_ORIGIN object:nil];
    }
}

- (void)myselfButtonClick:(id)sender
{
    UIButton *myselfBtn = (UIButton *)sender;
    if (!myselfBtn.selected) {
        self.originPlayButton.selected = NO;
        [self playerStartPlay];
    } else {
        [self playerStopPlay];
    }
}

- (void)saveClipButtonClick:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LL_AUDIO_CONTROL_SAVE_CLIP object:nil];
}

- (void)saveDubbingButtonClick:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LL_AUDIO_CONTROL_SAVE_DUBBING object:nil];
}

- (void)tapSpectrumViewAction:(id)tap
{
    [self recordEnd];
}

- (void)secondTimerChange
{
    _currRecordingSecond++;
    _spectrumView.timeLabel.text = [TimeUtils getMMSSFromSS:_currRecordingSecond];
}

#pragma mark functions

- (void)recordStart
{
    if (![self.audioRecorder isRecording]) {
//        [[AudioRecordClient defaultClient] setRecordAudioSession];
        [self playerStopPlay];
        self.originPlayButton.selected = NO;
        NSLog(@"录音开始");
        //        [[AudioRecordClient defaultClient] setRecordAudioSession];
        [self.audioRecorder record];
        _currRecordingSecond = 0;
        [self.secondTimer fire];
        _spectrumView.timeLabel.text = @"00:01";
        _microphoneDescLabel.text = @"Recording...Tap to stop";
        _recordingView.hidden = NO;
        [_spectrumView start];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LL_AUDIO_CONTROL_START_RECORD object:nil];
    }
}

- (void)recordEnd
{
//    [[AudioRecordClient defaultClient] setAudioSession];
    if ([self.audioRecorder isRecording]) {
        NSLog(@"取消");
        [self.audioRecorder stop];
        _currRecordingSecond = 0;
        [self stopSecondTimer];
        _spectrumView.timeLabel.text = @"00:00";
        [_spectrumView stop];
        _microphoneDescLabel.text = @"Tap to start record";
        _recordingView.hidden = YES;
        _audioPlayer = nil; //Player重置一下，不然不能播放
        
        self.recordPlayButton.enabled = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LL_AUDIO_CONTROL_END_RECORD object:nil];
    }
}

- (void)playerStartPlay
{
    _recordPlayButton.selected = YES;
    if (![self.audioPlayer isPlaying]) {
        [_audioPlayer prepareToPlay];
        [self.audioPlayer play];
        [[NSNotificationCenter defaultCenter] postNotificationName:LL_AUDIO_CONTROL_START_PLAY_MYSELF object:nil];
    }
}

- (void)playerStopPlay
{
    _recordPlayButton.selected = NO;
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:LL_AUDIO_CONTROL_END_PLAY_MYSELF object:nil];
}

- (void)enabledControlWithInitStatus
{
    self.microphoneButton.enabled = YES;
    self.originPlayButton.enabled = YES;
    self.recordPlayButton.enabled = NO;
    self.originPlayButton.selected = NO;
    self.recordPlayButton.selected = NO;
}

- (void)disabledAll
{
    self.originPlayButton.selected = NO;
    self.recordPlayButton.selected = NO;
    self.microphoneButton.enabled = NO;
    self.originPlayButton.enabled = NO;
    self.recordPlayButton.enabled = NO;
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
    }
}

- (void)stopSecondTimer
{
    if (_secondTimer.isValid) {
        [_secondTimer invalidate];
    }
    _secondTimer = nil;
}

@end
