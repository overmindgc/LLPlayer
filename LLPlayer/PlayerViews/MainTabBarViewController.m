//
//  MainTabBarViewController.m
//  LLPlayer
//
//  Created by 辰 宫 on 03/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.selectedIndex = 0;
    [self setTabBarItems];
//    self.tabBar.tintColor = [AppColor appMainColor];
    self.delegate = self;    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTabBarItems {
    CGFloat bgImageWidth = 0.0;
    if ([[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height) {
        bgImageWidth = [[UIScreen mainScreen] bounds].size.height / 3;
    } else {
        bgImageWidth = [[UIScreen mainScreen] bounds].size.width / 3;
    }
    CGSize indicatorImageSize =CGSizeMake(bgImageWidth, self.tabBar.bounds.size.height);
    self.tabBar.selectionIndicatorImage = [self drawTabBarItemBackgroundUmageWithSize:indicatorImageSize];
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, [UIFont systemFontOfSize:12.f],NSFontAttributeName,nil]forState:UIControlStateNormal];
        if (idx == 0) {
            obj.tabBarItem.image = [[UIImage imageNamed:@"video_tab_unactivate"]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//            obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabicon_message_active"]
//                                            imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else if (idx == 1) {
            obj.tabBarItem.image = [[UIImage imageNamed:@"dubbing_tab_unactivate"]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//            obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabicon_undo_active"]
//                                            imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else if (idx == 2) {
            obj.tabBarItem.image = [[UIImage imageNamed:@"setting_tab_unactivate"]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//            obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabicon_work_active"]
//                                            imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else {
            NSLog(@"Unknown TabBarController");
        }
    }];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSInteger vcIndex = [self.viewControllers indexOfObject:viewController];
    switch (vcIndex) {
        case 0:
            tabBarController.title = @"Videos";
            break;
        case 1:
            tabBarController.title = @"My Dubbing";
            break;
        case 2:
            tabBarController.title = @"Settings";
            break;
    }
}

//绘制图片
-(UIImage *)drawTabBarItemBackgroundUmageWithSize:(CGSize)size
{
    //开始图形上下文
    UIGraphicsBeginImageContext(size);
    //获得图形上下文
    CGContextRef ctx =UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(ctx,83/255.0,215/255.0,105/255.0, 1);
    CGContextFillRect(ctx,CGRectMake(0,0, size.width, size.height));
    
    
    CGRect rect =CGRectMake(0,0, size.width, size.height);
    CGContextAddEllipseInRect(ctx, rect);
    
    CGContextClip(ctx);
    
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    
    [image drawInRect:rect];
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
