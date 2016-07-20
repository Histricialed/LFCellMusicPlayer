//
//  LJAudioPlayerManager.h
//  UITableView
//
//  Created by LaFleur on 16/7/13.
//  Copyright © 2016年 Lianjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef void (^ReturnCurrentProgressBlock)(float value);
typedef void (^AudioPlayerFinishPlayingBlock)(BOOL flag, NSIndexPath *indexPath);


@interface LJAudioPlayerManager : NSObject<AVAudioPlayerDelegate>

@property (copy, nonatomic) ReturnCurrentProgressBlock returnCurrentProgressBlock;
@property (copy, nonatomic) AudioPlayerFinishPlayingBlock AudioPlayerFinishPlayingBlock;
@property (nonatomic, weak) NSIndexPath *playingCellIndexPath;

/**
 * @brief 获取该Manager的单例
 * @return N/A
 */
+ (instancetype)sharedInstance;


- (NSDictionary *)changePlayerStatusByCellStatus:(NSInteger)status andCellIndexPath:(NSIndexPath *)indexPath andCellVoiceURL:(NSURL *)voiceURL andCurrentProgress:(float)progress;

/**
 * @brief 根据滑块所处的进度设置播放器播放进度
 * @param progress 滑块拖动事件发生后变化的进度
 * @return N/A
 */
- (void)setPlayerProgressByProgress:(float)progress;

@end
