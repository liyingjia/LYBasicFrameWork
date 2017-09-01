//
//  LYBaseDataManager.m
//  LYBasicFrameWork
//
//  Created by liying on 17/8/31.
//  Copyright © 2017年 liying. All rights reserved.
//

#import "LYBaseDataManager.h"
#import "LYBaseCellItem.h"

@implementation LYBaseDataManager

- (LYBaseCellItem *)baseCellData{
    return [LYBaseCellItem new];
}

- (NSArray *)baseCellDatasWithDelegate{
    return [NSArray new];
}

- (NSArray *)baseCellDatas{
    LYBaseCellItem *item0 = [LYBaseCellItem new];
    item0.name = @"baseCell0";
    
    LYBaseCellItem *item1 = [LYBaseCellItem new];
    item1.name = @"baseCell1";
    return @[item0,item1];
}

@end
