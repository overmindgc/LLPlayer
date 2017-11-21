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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Settings";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
