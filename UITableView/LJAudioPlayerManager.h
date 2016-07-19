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

/**
 * @brief 获取该Manager的单例
 * @return N/A
 */
+ (instancetype)sharedInstance;

- (void)loadAudioWithURL:(NSURL *)audioURL andPlayingCellIndexPath:(NSIndexPath *)indexPath;

- (float)getCurrentProgress;

- (NSDictionary *)changePlayerStatusByCellStatus:(NSInteger)status andCellIndexPath:(NSIndexPath *)indexPath andCellVoiceURL:(NSURL *)voiceURL andCurrentProgress:(float)progress;

- (void)setPlayerProgressByProgress:(float)progress;

@end
