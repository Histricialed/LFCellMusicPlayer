//
//  BNRItemsViewController.m
//  UITableView
//
//  Created by 李志强 on 16/3/22.
//  Copyright © 2016年 Lianjia. All rights reserved.
//

#import "BNRItemsViewController.h"
#import "BNRItem.h"
#import "BNRItemStore.h"
#import "BNRItemCell.h"
#import "LJAudioPlayerManager.h"

#define WEAKSELF() __weak __typeof(&*self)weakSelf = self


@interface BNRItemsViewController()

@property (strong, nonatomic) NSMutableArray *timeArray;
@property (strong, nonatomic) NSMutableArray *cellStatusArray;

@end

@implementation BNRItemsViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"HomePwner";
//        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
//                                                                             target:self
//                                                                             action:@selector(addNewItem:)];
//        navItem.rightBarButtonItem = bbi;
        navItem.leftBarButtonItem = self.editButtonItem;
    }
    return self;
}

//- (IBAction)addNewItem:(id)sender
//{
//    BNRItem *newItem = [[BNRItemStore sharedStore] createItem];
//    NSInteger lastRow = [[[BNRItemStore sharedStore] allItems] indexOfObject:newItem];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath]
//                          withRowAnimation:UITableViewRowAnimationTop];
//}


//左划删除
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSArray *items = [[BNRItemStore sharedStore] allItems];
//        BNRItem *item = items[indexPath.row];
//        [[BNRItemStore sharedStore] removeItem:item];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.timeArray = [[NSMutableArray alloc] init];
    self.cellStatusArray = [[NSMutableArray alloc] init];
    UINib *nib = [UINib nibWithNibName:@"BNRItemCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"BNRItemCell"];
    for (int i = 0 ; i < 10 ; i++) {
        BNRItem *newItem = [[BNRItemStore sharedStore] createItem];
        NSInteger lastRow = [[[BNRItemStore sharedStore] allItems] indexOfObject:newItem];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allItems] count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAKSELF();
    __weak BNRItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNRItemCell"
                                                        forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSArray *items = [[BNRItemStore sharedStore] allItems];
    BNRItem *item = items[indexPath.row];

    cell.titleLabel.text = [NSString stringWithFormat:@"%ld%@",indexPath.row,item.itemName];
    cell.roomLabel.text = item.serialNumber;
    cell.priceLabel.text = [NSString stringWithFormat:@"%d万", item.valueInDollars];
    cell.indexPath = indexPath;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"myBundle" ofType:@"bundle"];
    cell.voiceURL = [[NSBundle bundleWithPath:bundlePath] URLForResource:[NSString stringWithFormat:@"%ld",indexPath.row] withExtension:@"m4a"];
    if ([self.timeArray count] <= indexPath.row) {
        [self.timeArray addObject:[NSNumber numberWithInt:0]];
    }
    if ([self.cellStatusArray count] <= indexPath.row) {
        [self.cellStatusArray addObject:[NSNumber numberWithInt:0]];
    }
    cell.returnSliderValueBlock = ^(float value,NSIndexPath *indexPath) {
        self.timeArray[indexPath.row] = [NSNumber numberWithFloat:value];
        if (cell.indexPath == indexPath) {
            [[LJAudioPlayerManager sharedInstance] setPlayerProgressByProgress:value];
        }
    };
    
    cell.controlButtonClickBlock = ^(NSIndexPath *indexPath,NSNumber *status,NSURL *voiceURL) {
        NSDictionary *resultDic = [[LJAudioPlayerManager sharedInstance] changePlayerStatusByCellStatus:[cell.status integerValue] andCellIndexPath:indexPath andCellVoiceURL:cell.voiceURL andCurrentProgress:[self.timeArray[indexPath.row] floatValue]];
        [self setArrayWithResultDic:resultDic withCurrentCell:cell];
    };
    
    return cell;
}

- (void)setArrayWithResultDic:(NSDictionary *)dic withCurrentCell:(BNRItemCell *)currentCell {
    NSIndexPath *usedPlayedCellIndexPath = [dic valueForKey:@"usedPlayedCellIndexPath"];
    int usedPlayedCellStatus = [[dic valueForKey:@"usedPlayedCellStatus"] intValue];
    NSIndexPath *currentCellIndexPath = [dic valueForKey:@"currentCellIndexPath"];
    int currentCellStatus = [[dic valueForKey:@"currentCellStatus"] intValue];
    
    if (currentCell.indexPath == currentCellIndexPath && [self.timeArray[currentCellIndexPath.row] floatValue] > 0) {
        [currentCell.voiceFollowSlider setValue:[self.timeArray[currentCellIndexPath.row] floatValue] animated:YES];
    }
    
    currentCell.status = [NSNumber numberWithInt:currentCellStatus];
    
    self.cellStatusArray[currentCellIndexPath.row] = [NSNumber numberWithInt:currentCellStatus];
    self.cellStatusArray[usedPlayedCellIndexPath.row] = [NSNumber numberWithInt:usedPlayedCellStatus];
    [currentCell setControlButtonType];
    
    [LJAudioPlayerManager sharedInstance].returnCurrentProgressBlock = ^(float progress) {
        if (currentCell.indexPath == currentCellIndexPath) {
            [currentCell.voiceFollowSlider setValue:progress animated:NO];
        }
        self.timeArray[currentCellIndexPath.row] = [NSNumber numberWithFloat:progress];
    };
    
    [LJAudioPlayerManager sharedInstance].AudioPlayerFinishPlayingBlock = ^(BOOL flag, NSIndexPath *indexPath) {
        BNRItemCell *finishedCell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (flag) {
            finishedCell.status = [NSNumber numberWithInt:0];
            [finishedCell setControlButtonType];
            if (finishedCell != currentCell) {
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            self.cellStatusArray[indexPath.row] = [NSNumber numberWithInt:0];
        }
    };
    
    BNRItemCell *usedPlayedCell = [self.tableView cellForRowAtIndexPath:usedPlayedCellIndexPath];
    if (usedPlayedCellStatus != -1 && usedPlayedCellIndexPath != currentCellIndexPath) {
        usedPlayedCell.status = [NSNumber numberWithInt:usedPlayedCellStatus];
        [usedPlayedCell setControlButtonType];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:usedPlayedCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[BNRItemCell class]]) {
        BNRItemCell *tmpCell = (BNRItemCell *)cell;
        if ([self.timeArray count] > indexPath.row) {
            tmpCell.voiceFollowSlider.value = [[self.timeArray objectAtIndex:indexPath.row] floatValue];
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        if ([self.cellStatusArray count] > indexPath.row) {
            tmpCell.status = [NSNumber numberWithInt:[[self.cellStatusArray objectAtIndex:indexPath.row] intValue]];
            [tmpCell setControlButtonType];
        }
    }
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[BNRItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


@end


