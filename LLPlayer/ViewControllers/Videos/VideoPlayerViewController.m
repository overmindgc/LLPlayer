//
//  VideoPlayerViewController.m
//  LLPlayer
//
//  Created by 辰 宫 on 05/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "SBPlayer.h"
#import <Masonry.h>

@interface VideoPlayerViewController ()

@property (nonatomic,strong) SBPlayer *player;

@property (nonatomic,strong) UIButton *backBtn;

@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.videoName;
//    self.view.backgroundColor = [UIColor whiteColor];
    //纯代码请用此种方法
    //http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8 直播网址
    //http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4
    //初始化播放器
//    self.player = [[SBPlayer alloc] initWithUrl:[NSURL URLWithString:@"http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8"]];
    self.player = [[SBPlayer alloc] initWithUrl:[NSURL fileURLWithPath:self.videoPath]];
    //设置标题
//    [self.player setTitle:@"这是一个标题"];
    //设置播放器背景颜色
    self.player.backgroundColor = [UIColor blackColor];
    //设置播放器填充模式 默认SBLayerVideoGravityResizeAspectFill，可以不添加此语句
    self.player.mode = SBLayerVideoGravityResizeAspectFill;
    //添加播放器到视图
    [self.view addSubview:self.player];
    //约束，也可以使用Frame
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top);
        make.height.mas_equalTo(@250);
    }];
    
    self.backBtn = [[UIButton alloc] init];
    [self.backBtn setImage:[UIImage imageNamed:@"video_back"] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(popVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
    }];
    /**
     使用xib请用第二种方法
     [self.player assetWithURL:[NSURL URLWithString:@"http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4"]];
     [self.player setTitle:@"这是一个标题"];
     */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.player stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark actions
- (IBAction)playOrPause:(id)sender {
    
    [self.player stop];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
