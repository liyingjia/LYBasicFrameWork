//
//  LTBaseTableViewCell.m
//  LYBasicFrameWork
//
//  Created by liying on 17/8/31.
//  Copyright © 2017年 liying. All rights reserved.
//

#import "LYBaseTableViewCell.h"

@implementation LYBaseTableViewCell

+ (CGFloat)cellHeightForData:(id)data
{
    return 60;
}

- (void)bindData:(LYBaseCellItem *)data
{
    self.textLabel.text = data.name;
}


@end
