//
//  MoviePlayerViewController.h
//  LLPlayer
//
//  Created by 辰 宫 on 09/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviePlayerViewController : UIViewController

/** 视频URL */
@property (nonatomic, strong) NSURL *videoURL;
/** 视频Title */
@property (nonatomic, copy) NSString *videoTitle;

@end
