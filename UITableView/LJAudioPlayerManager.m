//
//  LJAudioPlayerManager.m
//  UITableView
//
//  Created by LaFleur on 16/7/13.
//  Copyright © 2016年 Lianjia. All rights reserved.
//

#import "LJAudioPlayerManager.h"

@interface LJAudioPlayerManager()

@property (nonatomic, strong) AVAudioPlayer *privatePlayer;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LJAudioPlayerManager

/*manager的单例*/
+ (instancetype)sharedInstance
{
    static LJAudioPlayerManager * _instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

/*完整的描述请参见文件头部*/
- (void)loadAudioWithURL:(NSURL *)audioURL andPlayingCellIndexPath:(NSIndexPath *)indexPath {
    if ([self.privatePlayer isPlaying]) {
        [self.privatePlayer stop];
        self.privatePlayer = nil;
    }
    self.privatePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    self.privatePlayer.delegate = self;
}

/*播放音频，并设置timer定期更新播放进度	*/
- (void)playAudio {
    if (_timer ==nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
    [self.privatePlayer play];
}

/*暂停音频，并停止timer*/
- (void)pauseAudio {
    [_timer invalidate];
    _timer = nil;
    [self.privatePlayer pause];
}

/*切换音乐的时候需要停止，再继续载入*/
- (void)stopAudio {
    [_timer invalidate];
    _timer = nil;
    [self.privatePlayer stop];
    self.privatePlayer = nil;
}

/*获取当前播放器状态*/
- (int)getPlayerStatus {
    if ([self.privatePlayer isPlaying]) {
        return 1; // 播放
    } else if (self.privatePlayer) {
        return 2; // 暂停
    } else {
        return 0; // 停止
    }
}

/**
 * @brief 获取当前播放器的播放进度
 * @return progress播放进度
 */
- (float)getCurrentProgress {
    if (self.privatePlayer) {
        return self.privatePlayer.currentTime/self.privatePlayer.duration;
    } else {
        return 0;
    }
}

/**
 * @brief 播放器播放完成后的回调
 * @param player 播放器对象
 * @param flag 播放成功的标记
 * @return N/A
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.AudioPlayerFinishPlayingBlock) {
        self.AudioPlayerFinishPlayingBlock(flag,self.playingCellIndexPath);
    }
    [self stopAudio];
    self.playingCellIndexPath = nil;
}

/*完整的描述请参见文件头部*/
- (NSDictionary *)changePlayerStatusByCellStatus:(NSInteger)status andCellIndexPath:(NSIndexPath *)indexPath andCellVoiceURL:(NSURL *)voiceURL andCurrentProgress:(float)progress {
    NSDictionary *cellsStatus = [[NSDictionary alloc] init];
    if (!self.playingCellIndexPath) {
        [self loadAudioWithURL:voiceURL andPlayingCellIndexPath:indexPath];
        [self playAudio];
        [self setPlayerProgressByProgress:progress];
        cellsStatus = @{
            @"usedPlayedCellIndexPath": indexPath,
            @"usedPlayedCellStatus": [NSNumber numberWithInt:1],
            @"currentCellIndexPath": indexPath,
            @"currentCellStatus": [NSNumber numberWithInt:1]
        };
        self.playingCellIndexPath = indexPath;
        return cellsStatus;
    } else {
        switch ([self getPlayerStatus]) {
            case 0:
                [self loadAudioWithURL:voiceURL andPlayingCellIndexPath:indexPath];
                [self playAudio];
                [self setPlayerProgressByProgress:progress];
                cellsStatus = @{
                                @"usedPlayedCellIndexPath": self.playingCellIndexPath,
                                @"usedPlayedCellStatus": [NSNumber numberWithInt:-1],
                                @"currentCellIndexPath": indexPath,
                                @"currentCellStatus": [NSNumber numberWithInt:1]
                                };
                self.playingCellIndexPath = indexPath;
                return  cellsStatus;
                break;
                
            case 1:
                if (self.playingCellIndexPath.row == indexPath.row) {
                    [self pauseAudio];
                    cellsStatus = @{
                                    @"usedPlayedCellIndexPath": self.playingCellIndexPath,
                                    @"usedPlayedCellStatus": [NSNumber numberWithInt:2],
                                    @"currentCellIndexPath": indexPath,
                                    @"currentCellStatus": [NSNumber numberWithInt:2]
                                    };
                    return  cellsStatus;
                } else {
                    [self stopAudio];
                    [self loadAudioWithURL:voiceURL andPlayingCellIndexPath:indexPath];
                    [self playAudio];
                    [self setPlayerProgressByProgress:progress];
                    cellsStatus = @{
                                    @"usedPlayedCellIndexPath": self.playingCellIndexPath,
                                    @"usedPlayedCellStatus": [NSNumber numberWithInt:2],
                                    @"currentCellIndexPath": indexPath,
                                    @"currentCellStatus": [NSNumber numberWithInt:1]
                                    };
                    self.playingCellIndexPath = indexPath;
                    return  cellsStatus;
                }
                break;
                
            case 2:
                if (self.playingCellIndexPath.row == indexPath.row) {
                    [self playAudio];
                    [self setPlayerProgressByProgress:progress];
                    cellsStatus = @{
                                    @"usedPlayedCellIndexPath": self.playingCellIndexPath,
                                    @"usedPlayedCellStatus": [NSNumber numberWithInt:1],
                                    @"currentCellIndexPath": indexPath,
                                    @"currentCellStatus": [NSNumber numberWithInt:1]
                                    };
                    return  cellsStatus;
                } else {
                    [self stopAudio];
                    [self loadAudioWithURL:voiceURL andPlayingCellIndexPath:indexPath];
                    [self playAudio];
                    [self setPlayerProgressByProgress:progress];
                    cellsStatus = @{
                                    @"usedPlayedCellIndexPath": self.playingCellIndexPath,
                                    @"usedPlayedCellStatus": [NSNumber numberWithInt:2],
                                    @"currentCellIndexPath": indexPath,
                                    @"currentCellStatus": [NSNumber numberWithInt:1]
                                    };
                    self.playingCellIndexPath = indexPath;
                    return  cellsStatus;
                }
                break;
                
            default:
                break;
        }
    }
    return nil;
}

/**
 * @brief 播放器在播放时实时更新播放进度（用于更新slider）
 * @return N/A
 */
- (void)updateProgress{
    //进度条显示播放进度
    float progress = [self getCurrentProgress];
    if (self.returnCurrentProgressBlock) {
        self.returnCurrentProgressBlock(progress);
    }
}

/*完整的描述请参见文件头部*/
- (void)setPlayerProgressByProgress:(float)progress {
    if ([self.privatePlayer isPlaying]) {
        self.privatePlayer.currentTime = self.privatePlayer.duration * progress;
    }
}

@end
