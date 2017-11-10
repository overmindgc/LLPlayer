//
//  VideoPlayerViewController.h
//  LLPlayer
//
//  Created by 辰 宫 on 05/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerViewController : UIViewController

@property (nonatomic, copy) NSString *videoPath;

@property (nonatomic, copy) NSString *videoName;

@property (nonatomic) CGSize videoSize;

@end
