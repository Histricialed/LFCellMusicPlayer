//
//  BNRItem.m
//  RandomPossessions
//
//  Created by Joe Conway on 10/12/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BNRItem.h"

@interface BNRItem ()

@property (nonatomic, strong) NSDate *dateCreated;

@end

@implementation BNRItem

+ (id)randomItem
{
    // Create an array of three adjectives
    NSArray *randomAdjectiveList = @[@"声音文件"];
    NSInteger adjectiveIndex = rand() % [randomAdjectiveList count];
    NSString *randomName = [NSString stringWithFormat:@"%@",
                                randomAdjectiveList[adjectiveIndex]];
    int randomValue = rand() % 100 * 10;
    int randomRoom = rand() % 4;
    NSString *randomSerialNumber = [NSString stringWithFormat:@"%d-%d居 %c%c%c平",
                                        randomRoom,
                                        randomRoom + 1,
                                        '0' + rand() % 2,
                                        '0' + rand() % 10,
                                        '0' + rand() % 10];
    BNRItem *newItem =
        [[self alloc] initWithItemName:randomName
                        valueInDollars:randomValue
                          serialNumber:randomSerialNumber
         ];
    return newItem;
}

- (id)initWithItemName:(NSString *)name
        valueInDollars:(int)value
          serialNumber:(NSString *)sNumber
{
    
    // Call the superclass's designated initializer
    self = [super init];
    // Did the superclass's designated initializer succeed?
    if (self) {
        // Give the instance variables initial values
        self.itemName = name;
        self.serialNumber = sNumber;
        self.valueInDollars = value;
        self.dateCreated = [[NSDate alloc] init];
        
        NSUUID *uuid = [[NSUUID alloc] init];
        NSString *key = [uuid UUIDString];
        _itemKey = key;
    }
    
    // Return the address of the newly initialized object
    return self;
}

- (id)init {
    return [self initWithItemName:@"Item"
                   valueInDollars:0
                     serialNumber:@""];
}


- (void)dealloc
{
    NSLog(@"Destroyed: %@", self);
}

@end
