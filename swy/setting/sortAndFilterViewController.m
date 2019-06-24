//
//  sortAndFilterViewController.m
//  swy
//
//  Created by panyuwen on 2019/6/17.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "sortAndFilterViewController.h"
#import "swyManage.h"


@interface sortAndFilterViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong) UITableView      *tableView;
@property (nonatomic ,strong) UITextField      *screenKeyWordTF;
@end

@implementation sortAndFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    self.title = @"排序/筛选";
}

- (void)backAction
{
    [swyManage manage].screenKeyWord = self.screenKeyWordTF.text;
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITextField *)screenKeyWordTF
{
    if (!_screenKeyWordTF) {
        _screenKeyWordTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth-40, 40)];
        _screenKeyWordTF.borderStyle = UITextBorderStyleNone;
        _screenKeyWordTF.placeholder = @"筛选关键字输入 关键字之间以/分开";
        if ([swyManage manage].screenKeyWord) {
            _screenKeyWordTF.text = [swyManage manage].screenKeyWord;
        }
    }
    return _screenKeyWordTF;
}

- (UITableViewCell *)keyWordInputCell
{
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:self.screenKeyWordTF];
    return cell;
    
}



- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat Y =  [UIApplication sharedApplication].statusBarFrame.size.height+44;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-Y) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 40;
    }
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [self keyWordInputCell];
    }
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    return cell;
}





@end
