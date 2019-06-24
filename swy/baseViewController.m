//
//  baseViewController.m
//  swy
//
//  Created by panyuwen on 2019/6/17.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "baseViewController.h"
#import "backArrow.h"
#import "swyManage.h"

@interface baseViewController ()

@end

@implementation baseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
   
}

- (void)setTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor blackColor];
    self.navigationItem.titleView = titleLabel;

    
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        backArrow *arrow = [[backArrow alloc] initWithFrame:CGRectMake(0, 0, 12, 22)];
        [_backBtn addSubview:arrow];
        arrow.userInteractionEnabled = NO;
        arrow.backgroundColor = [UIColor clearColor];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}



@end
