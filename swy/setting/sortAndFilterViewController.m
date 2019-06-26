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
@property (nonatomic ,strong) UITextField      *lastModifyPersonTF;
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
    [swyManage manage].sortWordLastModifyPerson = self.lastModifyPersonTF.text;
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

- (UITextField *)lastModifyPersonTF
{
    if (!_lastModifyPersonTF) {
        _lastModifyPersonTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth-40, 40)];
        _lastModifyPersonTF.borderStyle = UITextBorderStyleNone;
        _lastModifyPersonTF.placeholder = @"输入最后修改人 之间以/分开";
        if ([swyManage manage].sortWordLastModifyPerson) {
            _lastModifyPersonTF.text = [swyManage manage].sortWordLastModifyPerson;
        }
    }
    return _lastModifyPersonTF;
}

- (UITableViewCell *)keyWordInputCell
{
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:self.screenKeyWordTF];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 39, ScreenWidth-40, 1)];
    line.backgroundColor = [UIColor grayColor];
    line.alpha = 0.5;
    [cell.contentView addSubview:line];
    return cell;
    
}

- (UITableViewCell *)lastModifyInputCell
{
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:self.lastModifyPersonTF];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 39, ScreenWidth-40, 1)];
    line.backgroundColor = [UIColor grayColor];
    line.alpha = 0.5;
    [cell.contentView addSubview:line];
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
    return 2;
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
        UITableViewCell *cell = [UITableViewCell new];
        cell.textLabel.text = @"优先展示包含以下公司名的公司";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        return cell;
    }else if (indexPath.row == 1) {
        return [self keyWordInputCell];
    }else if (indexPath.row == 2) {
        UITableViewCell *cell = [UITableViewCell new];
        cell.textLabel.text = @"最后修改人优先展示";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        return cell;
    }else if (indexPath.row == 3) {
        return [self lastModifyInputCell];
    }
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    return cell;
}





@end
