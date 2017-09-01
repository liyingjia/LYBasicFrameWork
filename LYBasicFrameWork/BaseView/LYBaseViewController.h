//
//  LYBaseViewController.h
//  LYBasicFrameWork
//
//  Created by liying on 17/8/31.
//  Copyright © 2017年 liying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKNavigationBarViewController.h"
#import "CCTableDataSourceHeader.h"
#import "LYBaseCellItem.h"
#import "LYBaseDataManager.h"
#import "MJRefresh.h"
#import "LYBaseTableViewCell.h"

@interface LYBaseViewController : GKNavigationBarViewController

@property (nonatomic, strong) CCTableDataItem *dataItem;
@property (nonatomic, strong) CCTableViewDelegate *ccDelegate;
@property (nonatomic, strong) CCTableViewDataSource *ccDataSource;

@property (nonatomic, strong) LYBaseDataManager *dataManager;

@property (nonatomic, strong) UITableView *tableView;

//获取网络数据
-(void)getNetData;

/**
  添加上拉加载部件
   @param selction 执行的方法
  */
- (void)addTableView:(UITableView *)tableview setRefreshHeaderSelection:(SEL)selction;
- (void)addCollection:(UICollectionView *)collection setRefreshHeaderSelection:(SEL)selction;


/**
 添加下拉加载部件
 @param selction 执行的方法 （加载完成时可以调用对应的方法改变状态，进方法实现部分）
 */
- (void)addTableView:(UITableView *)tableview setRefreshFooterSelection:(SEL)selction;
- (void)addCollection:(UICollectionView *)collection setRefreshFooterSelection:(SEL)selction;
@end
