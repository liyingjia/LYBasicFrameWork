//
//  LYBaseViewController.m
//  LYBasicFrameWork
//
//  Created by liying on 17/8/31.
//  Copyright © 2017年 liying. All rights reserved.
//

#import "LYBaseViewController.h"


@interface LYBaseViewController ()

@end

@implementation LYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self.ccDelegate;
    self.tableView.dataSource = self.ccDataSource;
    [self.tableView registerCellClass:[LYBaseTableViewCell class]];
//    [self addTableView:self.tableView setRefreshHeaderSelection:@selector(tableRefeshNew)];
//    [self addTableView:self.tableView setRefreshFooterSelection:@selector(tableRefeshMore)];
//    [self.view addSubview:self.tableView];
    [self getNetData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)getNetData{
//    [self.dataItem addCellClass:[LYBaseTableViewCell class] dataItems:[self.dataManager baseCellDatas] delegate:self];
//    [self.tableView reloadData];
}


//上拉加载
-(void)tableRefeshNew{
    
}

//加载更多
- (void)tableRefeshMore{
    
}

#pragma mark 添加TableView加载刷新控件

- (void)addTableView:(UITableView *)tableview setRefreshHeaderSelection:(SEL)selction{
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:selction];
    tableview.mj_header = header;
    
}

- (void)addTableView:(UITableView *)tableview setRefreshFooterSelection:(SEL)selction{
    
    MJRefreshBackNormalFooter* footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:selction];
    tableview.mj_footer = footer;
    
}

- (void)addCollection:(UICollectionView *)collection setRefreshHeaderSelection:(SEL)selction{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:selction];
    collection.mj_header = header;
}

- (void)addCollection:(UICollectionView *)collection setRefreshFooterSelection:(SEL)selction{
    MJRefreshBackNormalFooter* footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:selction];
    collection.mj_footer = footer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Getter && Setter
- (CCTableDataItem *)dataItem
{
    if (!_dataItem) {
        _dataItem = [CCTableDataItem dataItem];
    }
    return _dataItem;
}

- (CCTableViewDelegate *)ccDelegate
{
    if (!_ccDelegate) {
        _ccDelegate = [CCTableViewDelegate delegateWithDataItem:self.dataItem];
    }
    return _ccDelegate;
}

- (CCTableViewDataSource *)ccDataSource
{
    if (!_ccDataSource) {
        _ccDataSource = [CCTableViewDataSource dataSourceWithItem:self.dataItem];
    }
    return _ccDataSource;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64) style:UITableViewStylePlain];
    }
    return _tableView;
}

- (LYBaseDataManager *)dataManager
{
    if (!_dataManager) {
        _dataManager = [[LYBaseDataManager alloc] init];
    }
    return _dataManager;
}

@end
