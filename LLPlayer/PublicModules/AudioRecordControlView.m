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

@interface AudioRecordControlView () <AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (nonatomic, strong) UIButton *microphoneButton;

@property (nonatomic, strong) UIButton *originPlayButton;

@property (nonatomic, strong) UIButton *recordPlayButton;

@property (nonatomic, strong) UILabel *microphoneDescLabel;
@property (nonatomic, strong) UILabel *originDescLabel;
@property (nonatomic, strong) UILabel *myRecordDescLabel;

@property (nonatomic, strong) SpectrumView *spectrumView;

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *secondTimer;//计秒器

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
    [self addSubview:_microphoneButton];
    
    _originPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_originPlayButton setImage:[UIImage imageNamed:@"play_origin"] forState:UIControlStateNormal];
    [_originPlayButton setImage:[UIImage imageNamed:@"stop_play"] forState:UIControlStateSelected];
    [_originPlayButton addTarget:self action:@selector(originButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_originPlayButton];
    
    _recordPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_recordPlayButton setImage:[UIImage imageNamed:@"play_myself"] forState:UIControlStateNormal];
    [_recordPlayButton setImage:[UIImage imageNamed:@"stop_play"] forState:UIControlStateSelected];
    [_recordPlayButton addTarget:self action:@selector(myselfButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_recordPlayButton];
    
    _microphoneDescLabel = [[UILabel alloc] init];
    _microphoneDescLabel.text = @"Tip to start record";
    _microphoneDescLabel.font = [UIFont systemFontOfSize:14];
    _microphoneDescLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_microphoneDescLabel];
    
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
    _spectrumView.hidden = YES;
    UITapGestureRecognizer *tapGesturRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSpectrumViewAction:)];
    [_spectrumView addGestureRecognizer:tapGesturRecognizer];
    [self addSubview:_spectrumView];
    
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
    
    [_spectrumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(20);
        make.trailing.equalTo(self.mas_trailing).offset(-20);
        make.top.equalTo(self.mas_top).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(0);
    }];
}

#pragma mark record and play
/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
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
-(AVAudioPlayer *)audioPlayer{
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

///**
// *  录音声波监控定制器
// *
// *  @return 定时器
// */
//-(NSTimer *)timer{
//    if (!_timer) {
//        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
//    }
//    return _timer;
//}
//
///**
// *  录音声波状态设置
// */
//-(void)audioPowerChange{
//    [self.audioRecorder updateMeters];//更新测量值
//    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
//    CGFloat progress=(1.0/160.0)*(power+160.0);
//    [self.audioPower setProgress:progress];
//}

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
    _recordPlayButton.selected = NO;
}

#pragma mark actions
- (void)micButtonClick:(id)sender
{
    if (![self.audioRecorder isRecording]) {
        NSLog(@"录音开始");
        [self.audioRecorder record];
        _spectrumView.hidden = NO;
        [_spectrumView start];
    }
}

- (void)originButtonClick:(id)sender
{
    UIButton *orgBtn = (UIButton *)sender;
    orgBtn.selected = !orgBtn.selected;

}

- (void)myselfButtonClick:(id)sender
{
    UIButton *myselfBtn = (UIButton *)sender;
    myselfBtn.selected = !myselfBtn.selected;
    if (myselfBtn.selected) {
        if (![self.audioPlayer isPlaying]) {
            [self.audioPlayer play];
        }
    } else {
        if ([self.audioPlayer isPlaying]) {
            [self.audioPlayer stop];
        }
    }
}

- (void)tapSpectrumViewAction:(id)tap
{
    if ([self.audioRecorder isRecording]) {
        NSLog(@"取消");
        [self.audioRecorder stop];
        [_spectrumView stop];
        _spectrumView.hidden = YES;
    }
}

@end
