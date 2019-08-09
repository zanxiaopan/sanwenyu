//
//  settingViewController.m
//  swy
//
//  Created by panyuwen on 2019/6/12.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "settingViewController.h"
#import "heightSetViewController.h"
#import "sortAndFilterViewController.h"
#import "loginViewController.h"
#import "swyManage.h"
#import "webViewController.h"
#import "MBProgressHUD.h"

@interface settingViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic ,strong) UITableView       *tableView;
@property (nonatomic ,strong) UIButton          *logoutBtn;
@property (nonatomic ,strong) UISwitch          *autoRefreshSwitch;//自动刷新开关
@property (nonatomic, strong) UISwitch          *invertSwitch;//倒序开关
@end

@implementation settingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    self.title = @"设置";
    [self.view addSubview:self.logoutBtn];
    self.navigationController.navigationItem.leftBarButtonItem = nil;
}

- (void)logoutAction
{
    //清除cookie
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        if ([cookie.domain isEqualToString:@"sales.vemic.com"]) {
            [cookieJar deleteCookie:cookie];;
        }
    }
    
    [[swyManage manage].drawerController closeDrawerAnimated:false completion:^(BOOL finished) {
        loginViewController *loginVC = [[loginViewController alloc] initWithNibName:@"loginViewController" bundle:nil];
        [[swyManage manage].drawerController.centerViewController presentViewController:loginVC animated:YES completion:nil];
    }];
}

- (void)switchChanged:(UISwitch *)uiswitch
{
    if (uiswitch == self.autoRefreshSwitch) {
        [swyManage manage].autoRefreshList = _autoRefreshSwitch.isOn;
    }else {
        [swyManage manage].invertSwitch = _invertSwitch.isOn;
    }
    
}

- (UISwitch *)autoRefreshSwitch
{
    if (!_autoRefreshSwitch) {
        _autoRefreshSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(140, 0, 60, 30)];
        _autoRefreshSwitch.onTintColor = [UIColor orangeColor];
        [_autoRefreshSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _autoRefreshSwitch;
}

- (UISwitch *)invertSwitch {
    if (!_invertSwitch) {
        _invertSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(140, 0, 60, 30)];
        _invertSwitch.onTintColor = [UIColor orangeColor];
        [_invertSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _invertSwitch;
}

- (UIButton *)logoutBtn
{
    if (!_logoutBtn) {
        CGFloat maxY = [UIScreen mainScreen].bounds.size.height;
        CGFloat maxX = [UIScreen mainScreen].bounds.size.width;
        _logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(20,maxY-100 , 200-40, 45)];
        _logoutBtn.backgroundColor = [UIColor orangeColor];
        _logoutBtn.layer.cornerRadius = 5;
        _logoutBtn.layer.masksToBounds = YES;
        [_logoutBtn setTitle:@"退出登陆" forState:UIControlStateNormal];
        [_logoutBtn addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logoutBtn;
}


- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat Y =  [UIApplication sharedApplication].statusBarFrame.size.height+44;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-Y) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"客户列表 行高";
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"客户列表 排序/筛选";
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"我的客户列表";
    }else if (indexPath.row == 3) {
        cell.textLabel.text = @"添加新客户";
    }else if (indexPath.row == 4) {
        cell.textLabel.text = @"设置启动图";
    }
    else if ( indexPath.row == 5) {
        cell.textLabel.text = @"客户列表倒序";
        [cell.contentView addSubview:self.invertSwitch];
        self.invertSwitch.center = cell.contentView.center;
        self.invertSwitch.on = [swyManage manage].invertSwitch;
    }
    else{
        cell.textLabel.text = @"自动刷新";
        [cell.contentView addSubview:self.autoRefreshSwitch];
        self.autoRefreshSwitch.center = cell.contentView.center;
        self.autoRefreshSwitch.on = [swyManage manage].autoRefreshList;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        heightSetViewController *vc = [heightSetViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1) {
        [[swyManage manage].drawerController closeDrawerAnimated:false completion:^(BOOL finished) {
            sortAndFilterViewController *vc = [sortAndFilterViewController new];
            UINavigationController *nav = (UINavigationController *)[swyManage manage].drawerController.centerViewController;
            [nav pushViewController:vc animated:YES];
        }];
    }else if (indexPath.row == 2) {
        [[swyManage manage].drawerController closeDrawerAnimated:false completion:^(BOOL finished) {
            webViewController *vc = [webViewController new];
            UINavigationController *nav = (UINavigationController *)[swyManage manage].drawerController.centerViewController;
            [nav pushViewController:vc animated:YES];
            vc.urlStr = @"https://sales.vemic.com/customer.do?method=toCustomerList&selected=all";
        }];
    }else if (indexPath.row == 3) {
        [[swyManage manage].drawerController closeDrawerAnimated:false completion:^(BOOL finished) {
            webViewController *vc = [webViewController new];
            UINavigationController *nav = (UINavigationController *)[swyManage manage].drawerController.centerViewController;
            [nav pushViewController:vc animated:YES];
            vc.urlStr = @"http://sales.vemic.com/uitoolList.ui?funcID=40015&_i_f_k_=true&charlength=1000&pageLimit=50";
        }];
    }else if (indexPath.row == 4) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [[swyManage manage].drawerController presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<UIImagePickerControllerInfoKey, id> *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:^{
        [[swyManage manage] setLaunchImage:image];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[swyManage manage].drawerController.view animated:YES];
        hud.label.text = @"设置成功";
        [hud hideAnimated:YES afterDelay:0.5];
    
    }];
}

- (void)backAction
{
    [[swyManage manage].drawerController closeDrawerAnimated:false completion:^(BOOL finished) {

    }];
}



@end
