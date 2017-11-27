//
//  MoviePlayerViewController.m
//  LLPlayer
//
//  Created by 辰 宫 on 09/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "MoviePlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry/Masonry.h>
#import "ZFPlayer.h"
#import "UINavigationController+ZFFullscreenPopGesture.h"
#import "AudioRecordControlView.h"
#import "TimeUtils.h"
#import "AVUtils.h"
#import "AudioRecordClient.h"

@interface MoviePlayerViewController () <ZFPlayerDelegate>
/** 播放器View的父视图*/
@property (weak, nonatomic)  IBOutlet UIView *playerFatherView;
@property (strong, nonatomic) ZFPlayerView *playerView;
/** 离开页面时候是否在播放 */
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) ZFPlayerModel *playerModel;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIButton *startABtn;
@property (weak, nonatomic) IBOutlet UIButton *endBBtn;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet AudioRecordControlView *recordControlView;

@end

@implementation MoviePlayerViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@释放了",self.class);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // pop回来时候是否自动播放
    if (self.navigationController.viewControllers.count == 2 && self.playerView && self.isPlaying) {
        self.isPlaying = NO;
        self.playerView.playerPushedOrPresented = NO;
    }
    NSLog(@"B viewWillAppear");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"B viewDidAppear");
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"B viewDidDisappear");
}   

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // push出下一级页面时候暂停
    if (self.navigationController.viewControllers.count == 3 && self.playerView && !self.playerView.isPauseByUser)
    {
        self.isPlaying = YES;
        //        [self.playerView pause];
        self.playerView.playerPushedOrPresented = YES;
    }
    NSLog(@"B viewWillDisappear");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.zf_prefersNavigationBarHidden = YES;
    self.zf_interactivePopDisabled = NO;
    /*
     self.playerFatherView = [[UIView alloc] init];
     [self.view addSubview:self.playerFatherView];
     [self.playerFatherView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.mas_equalTo(20);
     make.leading.trailing.mas_equalTo(0);
     // 这里宽高比16：9,可自定义宽高比
     make.height.mas_equalTo(self.playerFatherView.mas_width).multipliedBy(9.0f/16.0f);
     }];
     */
    
    // 自动播放，默认不自动播放
    [self.playerView autoPlayTheVideo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordStartAction) name:LL_AUDIO_CONTROL_START_RECORD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordEndAction) name:LL_AUDIO_CONTROL_END_RECORD object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPlayMyselfAction) name:LL_AUDIO_CONTROL_START_PLAY_MYSELF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endPlayMyselfAction) name:LL_AUDIO_CONTROL_END_PLAY_MYSELF object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPlayOriginAction) name:LL_AUDIO_CONTROL_START_PLAY_ORIGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endPlayOriginAction) name:LL_AUDIO_CONTROL_END_PLAY_ORIGIN object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveClipAction) name:LL_AUDIO_CONTROL_SAVE_CLIP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveDubbingAction) name:LL_AUDIO_CONTROL_SAVE_DUBBING object:nil];
}

// 返回值要必须为NO
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // 这里设置横竖屏不同颜色的statusbar
    // if (ZFPlayerShared.isLandscape) {
    //    return UIStatusBarStyleDefault;
    // }
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return ZFPlayerShared.isStatusBarHidden;
}

#pragma mark - ZFPlayerDelegate

- (void)zf_playerBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)zf_playerDownload:(NSString *)url {
    
}

- (void)zf_playerControlViewWillShow:(UIView *)controlView isFullscreen:(BOOL)fullscreen {
    //    self.backBtn.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.backBtn.alpha = 0;
    }];
}

- (void)zf_playerControlViewWillHidden:(UIView *)controlView isFullscreen:(BOOL)fullscreen {
    //    self.backBtn.hidden = fullscreen;
    [UIView animateWithDuration:0.25 animations:^{
        self.backBtn.alpha = !fullscreen;
    }];
}

#pragma mark - Getter

- (ZFPlayerModel *)playerModel {
    if (!_playerModel) {
        _playerModel                  = [[ZFPlayerModel alloc] init];
        _playerModel.title            = _videoTitle;
        _playerModel.videoURL         = self.videoURL;
        _playerModel.placeholderImage = self.defaultThumblImg;
        _playerModel.fatherView       = self.playerFatherView;
        //        _playerModel.resolutionDic = @{@"高清" : self.videoURL.absoluteString,
        //                                       @"标清" : self.videoURL.absoluteString};
        _playerModel.isEnableSubTitleMask = YES;
    }
    return _playerModel;
}

- (ZFPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[ZFPlayerView alloc] init];
        
        /*****************************************************************************************
         *   // 指定控制层(可自定义)
         *   // ZFPlayerControlView *controlView = [[ZFPlayerControlView alloc] init];
         *   // 设置控制层和播放模型
         *   // 控制层传nil，默认使用ZFPlayerControlView(如自定义可传自定义的控制层)
         *   // 等效于 [_playerView playerModel:self.playerModel];
         ******************************************************************************************/
        [_playerView playerControlView:nil playerModel:self.playerModel];
        
        // 设置代理
        _playerView.delegate = self;
        
        //（可选设置）可以设置视频的填充模式，内部设置默认（ZFPlayerLayerGravityResizeAspect：等比例填充，直到一个维度到达区域边界）
        // _playerView.playerLayerGravity = ZFPlayerLayerGravityResize;
        
        // 打开下载功能（默认没有这个功能）
        _playerView.hasDownload    = NO;
        
        // 打开预览图
        self.playerView.hasPreviewView = YES;
        
    }
    return _playerView;
}

#pragma mark ZFPlayerDelegate

- (void)zf_playerRangePlayEndAction
{
    self.recordControlView.originPlayButton.selected = NO;
    [self.recordControlView recordEnd];
}

- (void)zf_playerRangeResetAction
{

}

#pragma mark - Action

- (void)recordStartAction
{
    self.playerView.mute = YES;
    
    [self.playerView startRangePlayOnMute:YES needPlay:YES];
}

- (void)recordEndAction
{
    [self.playerView pause];
}

- (void)startPlayOriginAction
{
    [self.playerView startRangePlayOnMute:NO needPlay:YES];
}

- (void)endPlayOriginAction
{
    [self.playerView startRangePlayOnMute:NO needPlay:NO];
}

- (void)startPlayMyselfAction
{
    [self.playerView startRangePlayOnMute:YES needPlay:YES];
}

- (void)endPlayMyselfAction
{
    self.playerView.mute = NO;
    
    [self.playerView pause];
}

- (IBAction)start_A_ButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    self.startTimeLabel.hidden = !btn.isSelected;
    
    if (btn.isSelected) {
        NSInteger startSec = [self.playerView setNowToRangeStartTime];
        self.startTimeLabel.text = [TimeUtils getMMSSFromSS:startSec];
        //如果AB全都设置
        if (self.endBBtn.isSelected) {
            if (self.playerView.rangeStartATime != self.playerView.rangeEndBTime) {
                //如果开始结束时间相反，就交换
                if (self.playerView.rangeStartATime > self.playerView.rangeEndBTime) {
                    [self.playerView exchangeStartAAndEndB];
                    NSString *tempStr = self.startTimeLabel.text;
                    self.startTimeLabel.text = self.endTimeLabel.text;
                    self.endTimeLabel.text = tempStr;
                }
                //可录音
                [self.recordControlView enabledControlWithInitStatus];
            }
            [self.playerView pause];
        }
    } else {
        //如果取消选择
        [self.recordControlView disabledAll];
        [self.playerView clearRangeAPoint];
    }
}

- (IBAction)start_B_ButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    self.endTimeLabel.hidden = !btn.isSelected;
    
    if (btn.isSelected) {
        NSInteger endSec = [self.playerView setNowToRangeEndTime];
        self.endTimeLabel.text = [TimeUtils getMMSSFromSS:endSec];
        //如果AB全都设置
        if (self.startABtn.isSelected) {
            if (self.playerView.rangeStartATime != self.playerView.rangeEndBTime) {
                //如果开始结束时间相反，就交换
                if (self.playerView.rangeStartATime > self.playerView.rangeEndBTime) {
                    [self.playerView exchangeStartAAndEndB];
                    NSString *tempStr = self.startTimeLabel.text;
                    self.startTimeLabel.text = self.endTimeLabel.text;
                    self.endTimeLabel.text = tempStr;
                }
                //可录音
                [self.recordControlView enabledControlWithInitStatus];
            }
        }
        [self.playerView pause];
    } else {
        //如果取消选择
        [self.recordControlView disabledAll];
        [self.playerView clearRangeBPoint];
    }
}

- (void)saveClipAction
{
    [self saveClipOrDubbing:NO];
}

- (void)saveDubbingAction
{
    [self saveClipOrDubbing:YES];
}

- (void)saveClipOrDubbing:(BOOL)isDubbing
{
    NSURL *recordUrl;
    if (isDubbing) {
        recordUrl = [[AudioRecordClient defaultClient] getSavePath];
    }
    NSString *fileName;
    if (recordUrl) {
        fileName = [NSString stringWithFormat:@"Dubbing_%0.f",[NSDate date].timeIntervalSince1970];
    } else {
        fileName = [NSString stringWithFormat:@"Clip_%0.f",[NSDate date].timeIntervalSince1970];
    }
    [AVUtils goSaveVideoPath:self.videoURL
               withStartTime:self.playerView.rangeStartATime
                 withEndTime:self.playerView.rangeEndBTime
                withFileName:fileName
              replaceByMusic:recordUrl
     ];
}

- (IBAction)backClick {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
