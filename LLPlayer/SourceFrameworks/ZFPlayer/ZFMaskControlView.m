//
//  ZFMaskControlView.m
//  LLPlayer
//
//  Created by GC on 22/02/2018.
//  Copyright © 2018 GC. All rights reserved.
//

#import "ZFMaskControlView.h"

@interface ZFMaskControlView ()

@property (nonatomic, strong) UILabel *styleLabel;
@property (nonatomic, strong) UIButton *blackBtn;
@property (nonatomic, strong) UIButton *whiteBtn;

@property (nonatomic, strong) UILabel *heightLabel;
@property (nonatomic, strong) UIButton *heighAddBtn;
@property (nonatomic, strong) UIButton *heighMinusBtn;

@property (nonatomic, strong) UILabel *leftRightLabel;
@property (nonatomic, strong) UIButton *leftAddBtn;
@property (nonatomic, strong) UIButton *leftMinusBtn;

@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, strong) UIButton *bottomAddBtn;
@property (nonatomic, strong) UIButton *bottomMinusBtn;


@end

@implementation ZFMaskControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self configUI];
    }
    
    return self;
}

- (void)configUI
{
    CGFloat lineHeight = 55;
    CGFloat textWidth = 30;
    CGFloat btnWidth = 50;
    CGFloat paddingTop = 0;
    self.styleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, paddingTop, textWidth, lineHeight)];
    self.styleLabel.text = @"样式";
    self.styleLabel.textColor = [UIColor whiteColor];
    self.styleLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:self.styleLabel];
    
    self.blackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.blackBtn.frame = CGRectMake(textWidth, paddingTop + (lineHeight - btnWidth) / 2, btnWidth, btnWidth);
    self.blackBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.blackBtn.layer.borderWidth = 0.5;
    self.blackBtn.layer.cornerRadius = 3;
    [self.blackBtn setTitle:@"黑" forState:UIControlStateNormal];
    [self.blackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.blackBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateSelected];
    self.blackBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [self.blackBtn addTarget:self action:@selector(blackBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.blackBtn];
    
    self.whiteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.whiteBtn.frame = CGRectMake(textWidth + btnWidth + 5, paddingTop + (lineHeight - btnWidth) / 2, btnWidth, btnWidth);
    self.whiteBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.whiteBtn.layer.borderWidth = 0.5;
    self.whiteBtn.layer.cornerRadius = 3;
    [self.whiteBtn setTitle:@"白" forState:UIControlStateNormal];
    [self.whiteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.whiteBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateSelected];
    self.whiteBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [self.whiteBtn addTarget:self action:@selector(whiteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.whiteBtn];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:ZF_MASK_STYLE_KEY] && [[defaults objectForKey:ZF_MASK_STYLE_KEY] integerValue] == UIBlurEffectStyleLight) {
        self.whiteBtn.selected = YES;
        self.whiteBtn.backgroundColor = [UIColor lightGrayColor];
    } else {
        self.blackBtn.selected = YES;
        self.blackBtn.backgroundColor = [UIColor lightGrayColor];
    }
    
    paddingTop = paddingTop + lineHeight;
    
    self.heightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, paddingTop, textWidth, lineHeight)];
    self.heightLabel.text = @"高度";
    self.heightLabel.textColor = [UIColor whiteColor];
    self.heightLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:self.heightLabel];
    
    self.heighMinusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.heighMinusBtn.frame = CGRectMake(textWidth, paddingTop + (lineHeight - btnWidth) / 2, btnWidth, btnWidth);
    self.heighMinusBtn.layer.cornerRadius = 3;
    self.heighMinusBtn.backgroundColor = [UIColor lightGrayColor];
    self.heighMinusBtn.alpha = 0.9;
    [self.heighMinusBtn setTitle:@"－" forState:UIControlStateNormal];
    [self.heighMinusBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    self.heighMinusBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.heighMinusBtn addTarget:self action:@selector(heighBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.heighMinusBtn];
    
    self.heighAddBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.heighAddBtn.frame = CGRectMake(textWidth + btnWidth + 5, paddingTop + (lineHeight - btnWidth) / 2, btnWidth, btnWidth);
    self.heighAddBtn.layer.cornerRadius = 3;
    self.heighAddBtn.backgroundColor = [UIColor lightGrayColor];
    self.heighAddBtn.alpha = 0.9;
    [self.heighAddBtn setTitle:@"＋" forState:UIControlStateNormal];
    [self.heighAddBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    self.heighAddBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.heighAddBtn addTarget:self action:@selector(heighBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.heighAddBtn];
    
    paddingTop = paddingTop + lineHeight;
    
    self.leftRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, paddingTop, textWidth, lineHeight)];
    self.leftRightLabel.text = @"左右";
    self.leftRightLabel.textColor = [UIColor whiteColor];
    self.leftRightLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:self.leftRightLabel];
    
    self.leftMinusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftMinusBtn.frame = CGRectMake(textWidth, paddingTop + (lineHeight - btnWidth) / 2, btnWidth, btnWidth);
    self.leftMinusBtn.layer.cornerRadius = 3;
    self.leftMinusBtn.backgroundColor = [UIColor lightGrayColor];
    self.leftMinusBtn.alpha = 0.9;
    [self.leftMinusBtn setTitle:@"－" forState:UIControlStateNormal];
    [self.leftMinusBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    self.leftMinusBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.leftMinusBtn addTarget:self action:@selector(leftRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftMinusBtn];
    
    self.leftAddBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftAddBtn.frame = CGRectMake(textWidth + btnWidth + 5, paddingTop + (lineHeight - btnWidth) / 2, btnWidth, btnWidth);
    self.leftAddBtn.layer.cornerRadius = 3;
    self.leftAddBtn.backgroundColor = [UIColor lightGrayColor];
    self.leftAddBtn.alpha = 0.9;
    [self.leftAddBtn setTitle:@"＋" forState:UIControlStateNormal];
    [self.leftAddBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    self.leftAddBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.leftAddBtn addTarget:self action:@selector(leftRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftAddBtn];
    
    paddingTop = paddingTop + lineHeight;
    
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, paddingTop, textWidth, lineHeight)];
    self.bottomLabel.text = @"底部";
    self.bottomLabel.textColor = [UIColor whiteColor];
    self.bottomLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:self.bottomLabel];
    
    self.bottomMinusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bottomMinusBtn.frame = CGRectMake(textWidth, paddingTop + (lineHeight - btnWidth) / 2, btnWidth, btnWidth);
    self.bottomMinusBtn.layer.cornerRadius = 3;
    self.bottomMinusBtn.backgroundColor = [UIColor lightGrayColor];
    self.bottomMinusBtn.alpha = 0.9;
    [self.bottomMinusBtn setTitle:@"－" forState:UIControlStateNormal];
    [self.bottomMinusBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    self.bottomMinusBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.bottomMinusBtn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.bottomMinusBtn];
    
    self.bottomAddBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bottomAddBtn.frame = CGRectMake(textWidth + btnWidth + 5, paddingTop + (lineHeight - btnWidth) / 2, btnWidth, btnWidth);
    self.bottomAddBtn.layer.cornerRadius = 3;
    self.bottomAddBtn.backgroundColor = [UIColor lightGrayColor];
    self.bottomAddBtn.alpha = 0.9;
    [self.bottomAddBtn setTitle:@"＋" forState:UIControlStateNormal];
    [self.bottomAddBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    self.bottomAddBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.bottomAddBtn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.bottomAddBtn];
}

- (void)blackBtnClick
{
    self.blackBtn.selected = !self.blackBtn.isSelected;
    if (self.blackBtn.isSelected) {
        self.blackBtn.backgroundColor = [UIColor lightGrayColor];
        self.whiteBtn.selected = NO;
        self.whiteBtn.backgroundColor = [UIColor clearColor];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInteger:UIBlurEffectStyleDark] forKey:ZF_MASK_STYLE_KEY];
        NSDictionary *userInfo = @{@"type":ZF_MASK_STYLE_KEY,
                                   @"value":@"black"};
        [[NSNotificationCenter defaultCenter] postNotificationName:ZF_MASK_CHANGE_CONFIG_NOTIFICATION object:nil userInfo:userInfo];
    } else {
        self.blackBtn.backgroundColor = [UIColor clearColor];
    }
}

- (void)whiteBtnClick
{
    self.whiteBtn.selected = !self.whiteBtn.isSelected;
    if (self.whiteBtn.isSelected) {
        self.whiteBtn.backgroundColor = [UIColor lightGrayColor];
        self.blackBtn.backgroundColor = [UIColor clearColor];
        self.blackBtn.selected = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInteger:UIBlurEffectStyleLight] forKey:ZF_MASK_STYLE_KEY];
        NSDictionary *userInfo = @{@"type":ZF_MASK_STYLE_KEY,
                                   @"value":@"white"};
        [[NSNotificationCenter defaultCenter] postNotificationName:ZF_MASK_CHANGE_CONFIG_NOTIFICATION object:nil userInfo:userInfo];
    } else {
        self.whiteBtn.backgroundColor = [UIColor clearColor];
    }
    
}

- (void)heighBtnClick:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat originHeight = [[defaults objectForKey:ZF_MASK_HEIGHT_KEY] floatValue];
    if (sender == self.heighAddBtn) {
        originHeight = originHeight + 2;
    } else {
        originHeight = originHeight - 2;
        if (originHeight < 0) {
            originHeight = 0;
        }
    }
    [defaults setObject:@(originHeight) forKey:ZF_MASK_HEIGHT_KEY];
    NSDictionary *userInfo = @{@"type":ZF_MASK_HEIGHT_KEY};
    [[NSNotificationCenter defaultCenter] postNotificationName:ZF_MASK_CHANGE_CONFIG_NOTIFICATION object:nil userInfo:userInfo];
}

- (void)leftRightBtnClick:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat leftPadding = [[defaults objectForKey:ZF_MASK_LEFT_RIGHT_KEY] floatValue];
    if (sender == self.leftAddBtn) {
        leftPadding = leftPadding + 2;
    } else {
        leftPadding = leftPadding - 2;
        if (leftPadding < 0) {
            leftPadding = 0;
        }
    }
    [defaults setObject:@(leftPadding) forKey:ZF_MASK_LEFT_RIGHT_KEY];
    NSDictionary *userInfo = @{@"type":ZF_MASK_LEFT_RIGHT_KEY};
    [[NSNotificationCenter defaultCenter] postNotificationName:ZF_MASK_CHANGE_CONFIG_NOTIFICATION object:nil userInfo:userInfo];
}

- (void)bottomBtnClick:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat bottomPadding = [[defaults objectForKey:ZF_MASK_BOTTOM_KEY] floatValue];
    if (sender == self.bottomAddBtn) {
        bottomPadding = bottomPadding + 2;
    } else {
        bottomPadding = bottomPadding - 2;
        if (bottomPadding < 0) {
            bottomPadding = 0;
        }
    }
    [defaults setObject:@(bottomPadding) forKey:ZF_MASK_BOTTOM_KEY];
    NSDictionary *userInfo = @{@"type":ZF_MASK_BOTTOM_KEY};
    [[NSNotificationCenter defaultCenter] postNotificationName:ZF_MASK_CHANGE_CONFIG_NOTIFICATION object:nil userInfo:userInfo];
}

@end
