//
//  BNRItemStore.h
//  UITableView
//
//  Created by LaFleur on 16/3/22.
//  Copyright © 2016年 Lianjia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BNRItem;

@interface BNRItemStore : NSObject

@property (nonatomic, readonly) NSArray *allItems;

+ (instancetype)sharedStore;
- (BNRItem *)createItem;
- (void)removeItem:(BNRItem *)item;
- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
