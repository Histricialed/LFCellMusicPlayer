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
@property (nonatomic, weak) NSIndexPath *playingCellIndexPath;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LJAudioPlayerManager

+ (instancetype)sharedInstance
{
    static LJAudioPlayerManager * _instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)loadAudioWithURL:(NSURL *)audioURL andPlayingCellIndexPath:(NSIndexPath *)indexPath {
    if ([self.privatePlayer isPlaying]) {
        [self.privatePlayer stop];
        self.privatePlayer = nil;
    }
    self.privatePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    self.privatePlayer.delegate = self;
}

- (void)playAudio {
    if (_timer ==nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
    [self.privatePlayer play];
}

- (void)pauseAudio {
    [_timer invalidate];
    _timer = nil;
    [self.privatePlayer pause];
}

- (void)stopAudio {
    [_timer invalidate];
    _timer = nil;
    [self.privatePlayer stop];
    self.privatePlayer = nil;
}

- (int)getPlayerStatus {
    if ([self.privatePlayer isPlaying]) {
        return 1; // 播放
    } else if (self.privatePlayer) {
        return 2; // 暂停
    } else {
        return 0; // 停止
    }
}

- (float)getCurrentProgress {
    if (self.privatePlayer) {
        return self.privatePlayer.currentTime/self.privatePlayer.duration;
    } else {
        return 0;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.AudioPlayerFinishPlayingBlock) {
        self.AudioPlayerFinishPlayingBlock(flag,self.playingCellIndexPath);
    }
    self.privatePlayer = nil;
    self.playingCellIndexPath = nil;
//    [_timer invalidate];
//    _timer = nil;
}

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

- (void)updateProgress{
    //进度条显示播放进度
    float progress = [self getCurrentProgress];
    if (self.returnCurrentProgressBlock) {
        self.returnCurrentProgressBlock(progress);
    }
}

- (void)setPlayerProgressByProgress:(float)progress {
    if ([self.privatePlayer isPlaying]) {
        self.privatePlayer.currentTime = self.privatePlayer.duration * progress;
    }
}

@end
