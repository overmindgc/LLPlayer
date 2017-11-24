//
//  ConfigViewController.m
//  LLPlayer
//
//  Created by 辰 宫 on 05/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "ConfigViewController.h"

@interface ConfigViewController ()

@end

@implementation ConfigViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1.第0组：3个
    [self add0SectionItems];
    
    // 2.第1组：6个
    [self add1SectionItems];
}

#pragma mark 添加第0组的模型数据
- (void)add0SectionItems
{
    __weak typeof(self) weakSelf = self;
    ZFSettingItem *subtitle = [ZFSettingItem itemWithIcon:@"subtitlemask" title:@"Default shield subtitle" type:ZFSettingItemTypeSwitch];
    //cell点击事件
    subtitle.switchBlock = ^(BOOL on) {
        
    };
    
    ZFSettingGroup *group = [[ZFSettingGroup alloc] init];
    group.header = @"Basic Settings";
    group.items = @[subtitle];
    [_allGroups addObject:group];
}

#pragma mark 添加第1组的模型数据
- (void)add1SectionItems
{
    __weak typeof(self) weakSelf = self;
    // 帮助
    ZFSettingItem *help = [ZFSettingItem itemWithIcon:@"MoreHelp" title:@"Help" type:ZFSettingItemTypeArrow];
    help.operation = ^{
        
    };
    
    // 分享
    ZFSettingItem *share = [ZFSettingItem itemWithIcon:@"MoreShare" title:@"Share to WeChat" type:ZFSettingItemTypeArrow];
    share.operation = ^{
        
    };
    
    // 关于
    ZFSettingItem *about = [ZFSettingItem itemWithIcon:@"MoreAbout" title:@"About app" type:ZFSettingItemTypeArrow];
    about.operation = ^{
        
    };
    
    ZFSettingGroup *group = [[ZFSettingGroup alloc] init];
    group.header = @"Other";
    group.items = @[ help, share , about];
    [_allGroups addObject:group];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
