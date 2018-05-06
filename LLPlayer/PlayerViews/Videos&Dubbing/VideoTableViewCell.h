//
//  VideoTableViewCell.h
//  LLPlayer
//
//  Created by 辰 宫 on 05/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *propertyLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastLabel;

@end
