//
//  heightSetViewController.m
//  swy
//
//  Created by panyuwen on 2019/6/17.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "heightSetViewController.h"
#import "swyManage.h"
#import "heightSetCell.h"

@interface heightSetViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong) UITableView      *tableView;
@end

@implementation heightSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    self.title = @"高度设置";
}

- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat Y =  [UIApplication sharedApplication].statusBarFrame.size.height+44;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-Y) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:@"heightSetCell" bundle:nil] forCellReuseIdentifier:@"heightSetCell"];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    heightSetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"heightSetCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(indexPath.row+4)*5];
    cell.rightImg.hidden = [swyManage manage].lineHeight != (indexPath.row+4)*5;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [swyManage manage].lineHeight = (indexPath.row+4)*5;
    [tableView reloadData];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
