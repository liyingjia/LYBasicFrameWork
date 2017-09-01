//
//  HomeViewController.m
//  LYBasicFrameWork
//
//  Created by liying on 17/8/31.
//  Copyright © 2017年 liying. All rights reserved.
//

#import "HomeViewController.h"
#import "WyhShowEmpty.h"
#import "JXPopoverView.h"
#import "AddViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.gk_navBarTintColor   = [UIColor redColor];
    
//    self.tableView.backgroundColor = [UIColor cyanColor];
        [self.view addSubview:self.tableView];
//    [self wyh_showEmptyMsg:@"暂无内容" dataCount:0];
//    [self wyh_showEmptyMsg:@"点击刷新" dataCount:0 isHasBtn:YES Handler:^{
//        NSLog(@"111");
//    }];
    
    /*自定义视图设置*/
//    WyhEmptyStyle *style = [[WyhEmptyStyle alloc]init];
//    style.tipText = @"转了一圈又一圈";
//    style.tipTextColor = [UIColor brownColor];
//    style.btnTipText = @"消失";
//    style.imageConfig.type = GifImgLocalUrl;
//    style.refreshStyle = RefreshClickOnBtnStyle;
//    style.btnWidth = 100;
//    style.btnHeight = 100;
//    style.btnLayerCornerRadius = 50;
//    style.btnLayerBorderColor = [UIColor redColor];
//    self.wyhEmptyStyle = style;
//    
//    [self wyh_showWithStyle:style];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:@"弹框" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showView:) forControlEvents:UIControlEventTouchUpInside];
    self.gk_navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self setTableDelegate];
}


-(void)getNetData{
        [self.dataItem addCellClass:[LYBaseTableViewCell class] dataItems:[self.dataManager baseCellDatas] delegate:self];
        [self.tableView reloadData];
}


- (void)setTableDelegate
{
    WeakSelf(self);
    
    [self.ccDelegate setDidSelectRowAtIndexPath:^(UITableView *tableView, NSIndexPath *indexPath, id rowData, NSString *cellClassName) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        AddViewController *vc= [AddViewController new];
        [weakself.navigationController pushViewController:vc animated:YES];
    }];
}



-(void)showView:(UIButton *)item{
    
    JXPopoverView *popoverView = [JXPopoverView popoverView];
    JXPopoverAction *action1 = [JXPopoverAction actionWithTitle:@"钓点" handler:^(JXPopoverAction *action) {
        
        NSLog(@"-------点击了钓点");
        
    }];
    
    JXPopoverAction *action2 = [JXPopoverAction actionWithTitle:@"渔具店" handler:^(JXPopoverAction *action) {
        
        NSLog(@"-------点击了渔具店");
    }];
    
    
    JXPopoverAction *action3 = [JXPopoverAction actionWithTitle:@"饭店" handler:^(JXPopoverAction *action) {
        NSLog(@"-------点击了饭店");
        
    }];
    
    
    JXPopoverAction *action4 = [JXPopoverAction actionWithTitle:@"酒店" handler:^(JXPopoverAction *action) {
        
        NSLog(@"-------点击了酒店");
    }];
    
    
    JXPopoverAction *action5 = [JXPopoverAction actionWithTitle:@"活动" handler:^(JXPopoverAction *action) {
        
        NSLog(@"-------点击了活动");
    }];
    [popoverView showToView:item withActions:@[action1,action2,action3,action4,action5]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
