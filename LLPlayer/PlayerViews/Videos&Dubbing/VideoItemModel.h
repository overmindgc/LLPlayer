//
//  VideoItemModel.h
//  LLPlayer
//
//  Created by 辰 宫 on 05/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoItemModel : NSObject

@property (nonatomic, strong) AVURLAsset *videoAsset;

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *totalTime;
@property (nonatomic, copy) NSString *resolution;
@property (nonatomic, copy) NSString *encoding;

@property (nonatomic) CGSize videoSize;
@property (nonatomic, strong) UIImage *thumbImage;

@property (nonatomic) BOOL canPlay;
@property (nonatomic) BOOL isFolder;

@end
