//
//  LYBaseDataManager.h
//  LYBasicFrameWork
//
//  Created by liying on 17/8/31.
//  Copyright © 2017年 liying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYBaseCellItem.h"

@interface LYBaseDataManager : NSObject

- (LYBaseCellItem *)baseCellData;

- (NSArray *)baseCellDatasWithDelegate;

- (NSArray *)baseCellDatas;

@end
