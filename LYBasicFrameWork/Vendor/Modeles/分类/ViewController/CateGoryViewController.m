//
//  CateGoryViewController.m
//  LYBasicFrameWork
//
//  Created by liying on 17/8/31.
//  Copyright © 2017年 liying. All rights reserved.
//

#import "CateGoryViewController.h"
#import "MMPopupItem.h"
#import "MMAlertView.h"
#import "MMSheetView.h"
#import "MMPopupWindow.h"

@interface CateGoryViewController ()

@end

@implementation CateGoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    
     [MMAlertViewConfig globalConfig];
     [MMSheetViewConfig globalConfig];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    /**alert不带标题的**/
    MMPopupItemHandler block = ^(NSInteger index){
        NSLog(@"clickd %@ button",@(index));
    };
    NSArray *items =
    @[MMItemMake(@"Done", MMItemTypeNormal, block),
      MMItemMake(@"Save", MMItemTypeNormal, block),
      MMItemMake(@"Cancel", MMItemTypeNormal, block)];
    
    MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:nil
                                                         detail:nil
                                                          items:items];
    //            alertView.attachedView = self.view;
    //            alertView.attachedView.mm_dimBackgroundBlurEnabled = YES;
    //            alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleLight;
    
    [alertView show];
    
    /**actionsheet弹框**/
    
    //    MMPopupCompletionBlock completeBlock = ^(MMPopupView *popupView, BOOL finished){
    //        NSLog(@"animation complete");
    
    //    NSArray *items =
    //    @[MMItemMake(@"Normal", MMItemTypeNormal, block),
    //      MMItemMake(@"Highlight", MMItemTypeHighlight, block),
    //      MMItemMake(@"Disabled", MMItemTypeDisabled, block)];
    //
    //    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:@"SheetView"
    //                                                          items:items];
    //    sheetView.attachedView = self.view;
    //    sheetView.attachedView.mm_dimBackgroundBlurEnabled = NO;
    //    [sheetView showWithBlock:completeBlock];
    //    };
    
    /**alert带标题的**/
    //    MMAlertView *alertView = [[MMAlertView alloc] initWithConfirmTitle:@"AlertView" detail:@"Confirm Dialog"];
    //    alertView.attachedView = self.view;
    //    alertView.attachedView.mm_dimBackgroundBlurEnabled = YES;
    //    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleDark;
    //    [alertView showWithBlock:completeBlock];
    
    /**alertview带输入框的**/
    //    MMAlertView *alertView = [[MMAlertView alloc] initWithInputTitle:@"AlertView" detail:@"Input Dialog" placeholder:@"Your placeholder" handler:^(NSString *text) {
    //        NSLog(@"input:%@",text);
    //    }];
    //    alertView.attachedView = self.view;
    //    alertView.attachedView.mm_dimBackgroundBlurEnabled = YES;
    //    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleExtraLight;
    //    [alertView showWithBlock:completeBlock];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
