//
//  LFCellMusicPlayerTableViewCell.h
//  UITableView
//
//  Created by LaFleur on 16/3/22.
//  Copyright © 2016年 Lianjia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  NS_ENUM(NSUInteger, ELJVoiceStatus) {
    ELJVoiceStatusStop = 0,
    ELJVoiceStatusPlay,
    ELJVoiceStatusPause
};

typedef void (^ReturnSliderValueBlock)(float value,NSIndexPath *indexPath);
typedef void (^ControlButtonClickBlock)(NSIndexPath *indexPath,NSNumber *status,NSURL *voiceURL);

@interface LFCellMusicPlayerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *controlButton;
@property (weak, nonatomic) IBOutlet UISlider *voiceFollowSlider;
@property (weak, nonatomic) NSIndexPath *indexPath;
@property (copy, nonatomic) NSURL *voiceURL;

@property (copy, nonatomic) ReturnSliderValueBlock returnSliderValueBlock;
@property (copy, nonatomic) ControlButtonClickBlock controlButtonClickBlock;

@property (assign, nonatomic) NSNumber *status;  // 0停止 1播放 2暂停

- (void)setControlButtonType;

- (void)setSliderValue:(float)sliderValue;

@end
