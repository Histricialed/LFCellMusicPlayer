//
//  BNRItemCell.m
//  UITableView
//
//  Created by 李志强 on 16/3/22.
//  Copyright © 2016年 Lianjia. All rights reserved.
//

#import "BNRItemCell.h"

@implementation BNRItemCell

- (IBAction)clickControlButton:(id)sender {
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.voiceFollowSlider.value = 0;
        
    self.status = ELJVoiceStatusStop;
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"myBundle" ofType:@"bundle"];
    self.voiceURL = [[NSBundle bundleWithPath:bundlePath] URLForResource:[NSString stringWithFormat:@"%ld",self.indexPath.row] withExtension:@"m4a"];
    
    [self.voiceFollowSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.controlButton addTarget:self action:@selector(controlButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.status = 0;
}

- (void)sliderValueChanged:(id)sender {
    if([sender isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)sender;
        if (self.returnSliderValueBlock) {
            self.returnSliderValueBlock(slider.value, self.indexPath);
        }
    }
}

- (void)setSliderValue:(float)sliderValue {
    self.voiceFollowSlider.value = sliderValue;
}

- (void)controlButtonClick:(id)sender {
    if (self.controlButtonClickBlock) {
        self.controlButtonClickBlock(self.indexPath,self.status,self.voiceURL);
        [self setControlButtonType];
    }
}

- (void)setControlButtonType {
    switch ([self.status integerValue]) {
        case ELJVoiceStatusStop:
            [self.controlButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
            self.voiceFollowSlider.enabled = NO;
            break;
            
        case ELJVoiceStatusPlay:
            [self.controlButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
            self.voiceFollowSlider.enabled = YES;
            break;
            
        case ELJVoiceStatusPause:
            [self.controlButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
            self.voiceFollowSlider.enabled = NO;
            break;
            
        default:
            break;
    }
}


@end
