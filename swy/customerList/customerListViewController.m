//
//  customerListViewController.m
//  swy
//
//  Created by panyuwen on 2019/6/10.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "customerListViewController.h"
#import "TFHpple.h"
#import "loginViewController.h"
#import "customerInfoCell.h"
#import "NSMutableURLRequest+header.h"
#import "settingViewController.h"
#import "swyManage.h"
#import "MJRefresh.h"
#import "TFHppleElement+swy.h"
#import "MBProgressHUD.h"


@interface customerListViewController ()<NSURLSessionDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIButton      *refreshBtn;
@property (nonatomic, strong) UIButton      *settingBtn;
@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) NSArray       *dataSource;

@property (nonatomic, strong) NSString          *token;
@property (nonatomic, strong) NSString          *customerId;
@property (nonatomic, strong) NSMutableDictionary      *customDict;//customerId:customName
@property (nonatomic, strong) NSString          *formToken;
@property (nonatomic, strong) NSString          *successUrlString;
@property (nonatomic, strong) NSURLSession      *session;
@property (nonatomic, strong) MJRefreshStateHeader     *refreshHeader;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSURLSessionTask *currentTask;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIButton *floatBtn;
@property (nonatomic, strong) UILabel  *floatSumLabel;
@property (nonatomic, assign) NSInteger  sum;
@property (nonatomic, strong) UILabel  *resultLabel;

@end

@implementation customerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.refreshBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicator];
    self.title  = @"swy";
    self.customDict = [NSMutableDictionary dictionary];
    //[self.view addSubview:self.imageView];
    [self.view addSubview:self.tableView];
    self.tableView.mj_header = self.refreshHeader;
    self.imageView.userInteractionEnabled = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:self.floatBtn];
    [self.view addSubview:self.floatSumLabel];
    [[UIApplication sharedApplication].keyWindow addSubview:self.resultLabel];
    [[swyManage manage] addObserver:self forKeyPath:@"settedCustomAutoClickSwitch" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    self.floatBtn.hidden = ![swyManage manage].settedCustomAutoClickSwitch;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self requesList];
    
}

- (NSURLSession *)session
{
    if (!_session) {
        _session  = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return _session;
}

- (UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.hidesWhenStopped = YES;
    }
    return _indicator;
}

- (MJRefreshStateHeader *)refreshHeader
{
    if (!_refreshHeader) {
        _refreshHeader = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            [self requesList];
        }];

        if ([swyManage manage].isBirthDay) {
            _refreshHeader.lastUpdatedTimeText = ^NSString *(NSDate *lastUpdatedTime) {
                return @"生日快乐🎉🎉";
            };
            [_refreshHeader setTitle:@"小珊珊" forState:MJRefreshStateIdle];
            [_refreshHeader setTitle:@"快放开我！" forState:MJRefreshStatePulling];
            [_refreshHeader setTitle:@"loading" forState:MJRefreshStateRefreshing];
            [_refreshHeader setTitle:@"小珊珊" forState:MJRefreshStateWillRefresh];
            [_refreshHeader setTitle:@"小珊珊" forState:MJRefreshStateNoMoreData];
        }else{
            _refreshHeader.lastUpdatedTimeText = ^NSString *(NSDate *lastUpdatedTime) {
                return @"三文鱼";
            };
        }
        _refreshHeader.lastUpdatedTimeLabel.textColor = [UIColor orangeColor];
        _refreshHeader.stateLabel.textColor = [UIColor orangeColor];

    }
    return _refreshHeader;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _imageView.alpha = 0.7;
        _imageView.image = [UIImage imageNamed:@"WechatIMG45.jpeg"];
    }
    return _imageView;
}

- (UIButton *)refreshBtn
{
    if (!_refreshBtn) {
        _refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_refreshBtn setTitle:@"🍣" forState:UIControlStateNormal];
        _refreshBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [_refreshBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}

-(UIButton *)settingBtn
{
    if (!_settingBtn) {
        _settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_settingBtn setTitle:@"设置" forState:UIControlStateNormal];
        [_settingBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        _settingBtn.frame = CGRectMake(0, 0, 30, 30);
        [_settingBtn addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingBtn;
}

- (UIButton *)floatBtn {
    if (!_floatBtn) {
        _floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _floatBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_floatBtn setTitle:@"抢" forState:UIControlStateNormal];
        [_floatBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _floatBtn.frame = CGRectMake(10,[UIScreen mainScreen].bounds.size.height-100, 50, 50);
        _floatBtn.layer.cornerRadius = 25;
        _floatBtn.layer.masksToBounds = YES;
        [_floatBtn addTarget:self action:@selector(qiangkehu) forControlEvents:UIControlEventTouchUpInside];
        _floatBtn.hidden = ![swyManage manage].settedCustomAutoClickSwitch;
        _floatBtn.backgroundColor = [UIColor orangeColor];
    }
    return _floatBtn;
}

- (UILabel *)floatSumLabel {
    if (!_floatSumLabel) {
        _floatSumLabel = [[UILabel alloc] init];
        _floatSumLabel.alpha = 0.75;
        _floatSumLabel.font = [UIFont systemFontOfSize:15];
        _floatSumLabel.text = @"今日抢客户总数:0";
        _floatSumLabel.textColor = [UIColor orangeColor];
        _floatSumLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-130,[UIScreen mainScreen].bounds.size.height-120,130, 50);
    }
    return _floatSumLabel;
}

- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.alpha = 0.75;
        _resultLabel.font = [UIFont systemFontOfSize:15];
        _resultLabel.text = @"";
        _resultLabel.textColor = [UIColor orangeColor];
        _resultLabel.frame = CGRectMake(50,20,250, 50);
    }
    return _resultLabel;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat Y = [UIApplication sharedApplication].statusBarFrame.size.height+44;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,Y , [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-Y)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerNib:[UINib nibWithNibName:@"customerInfoCell" bundle:nil] forCellReuseIdentifier:@"customerInfoCell"];
    }
    return _tableView;
}

#pragma mark Action
- (void)qiangkehu {
    if (_dataSource.count) {
        int randomNum = (arc4random() % _dataSource.count);
        TFHppleElement *elementAll = _dataSource[randomNum];
        NSArray<TFHppleElement *> *array = [elementAll searchWithXPathQuery:@"//td"];//10个数据
        TFHppleElement *elemnent1 = [[array[3] searchWithXPathQuery:@"//a"] objectAtIndex:0];
        NSString *url = [elemnent1.attributes objectForKey:@"href"];
        [self showRobAcc:[NSString stringWithFormat:@"https://sales.vemic.com%@",url]];
    }

    
}

- (void)refreshAction
{
    [self requesList];
}

- (void)settingAction
{
    settingViewController *vc = [[settingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)requesList
{
    if (self.navigationController.viewControllers.firstObject != self) {
        return;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.indicator startAnimating];
    if (!isDevlopping) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://sales.vemic.com/customer.do?method=listRobAccount"]];
        [request configDefaultRequestHeader];
        NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshHeader endRefreshing];
                [self.indicator stopAnimating];
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=listRobAccount💗💗💗💗💗💗💗💗%@",htmlStr);
                TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
                if (![self presentLogin:tfhpple url:response.URL.absoluteString]) {
                    NSArray *array = [tfhpple searchWithXPathQuery:@"//tr[@class='odd']"];
                    if (array.count) {
                        self.dataSource = array;
                        if (![swyManage manage].settedCustomAutoClickSwitch) {
                            [self sortList];
                            [self.tableView reloadData];
                        }else{
                            BOOL haveFound = [self sortList];
                            if (!haveFound) {
                                [self restartRefreshTimer];
                            }else {
                                self.dataSource = nil;
                            }
                            [self.tableView reloadData];
                        }
                    }else{
                        self.dataSource = nil;
                        [self.tableView reloadData];
                        if ([swyManage manage].autoRefreshList) {
                            [self restartRefreshTimer];
                        }
                    }
                }else{
                    NSLog(@"未登录:%@",response.URL.absoluteString);
                }

            });
        }];
        [task resume];
    }else{
        [self.refreshHeader endRefreshing];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self.indicator stopAnimating];
        });
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"customerList.html" withExtension:nil];
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *array = [tfhpple searchWithXPathQuery:@"//tr[@class='odd']"];
        if (array.count) {
            self.dataSource = array;
            if (![swyManage manage].settedCustomAutoClickSwitch) {
                [self sortList];
                [self.tableView reloadData];
            }else{
                BOOL haveFound = [self sortList];
                if (!haveFound) {
                    [self restartRefreshTimer];
                }
                [self.tableView reloadData];
            }
        }
    }

}

- (void)restartRefreshTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(requesList) userInfo:nil repeats:NO];

}

//点击某个客户
- (void) showRobAcc:(NSString *)urlStr
{
    self.dataSource = nil;
    [self.tableView reloadData];
    //showRobAcc
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request addValue:@"https://sales.vemic.com/customer.do?method=listRobAccount" forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    
    self.currentTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isDevlopping) {
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=showRobAcc💗💗💗💗💗💗💗💗%@",htmlStr);
                TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
                if (![self presentLogin:tfhpple url:response.URL.absoluteString]) {
                    NSDictionary *dic = [self dictionaryWith:response.URL.absoluteString];
                    if (dic[@"customerId"]) {
                        self.token = dic[@"token"];
                        self.customerId = dic[@"customerId"];
                         [self accountDetail];
                    }else{
                        [self showAlertAndRefresh:@"未获取到token或者customerId"];
                        return;
                    }
                }else{
                    NSLog(@"未登录:%@",response.URL.absoluteString);
                }
            }else{
                [self accountDetail];
            }
        });
    }];
    [self.currentTask resume];
    
}

- (void)accountDetail
{
    if (!isDevlopping) {
        if (!self.customerId.length || !self.token.length) {
            [self showAlertAndRefresh:@"未获取到token或者customerId"];
            return;
        }
    }
    
    NSString *curURLStr  = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=accountDetails&customerId=%@&token=%@",self.customerId,self.token];
    NSString *referer = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=details&customerId=%@&token=%@",self.customerId,self.token];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:curURLStr]];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    self.currentTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isDevlopping) {
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=accountDetail💗💗💗💗💗💗💗💗%@",htmlStr);
                TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
                if (![self presentLogin:tfhpple url:response.URL.absoluteString]) {
                    TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
                    NSArray<TFHppleElement *> *array = [tfhpple searchWithXPathQuery:@"//input[@name='FORM.TOKEN']"];
                    if (array.count) {
                        self.formToken = [array[0].attributes objectForKey:@"value"];
                        [self clickNoOpen];
                    }else{
                        [self showAlertAndRefresh:@"未取到FORM.TOKEN"];
                    }
                }else{
                   NSLog(@"未登录");
                }
            }else{
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"detail.html" withExtension:nil];
                NSData *data2 = [[NSData alloc] initWithContentsOfURL:url];
                TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data2];
                NSArray<TFHppleElement *> *array1 = [tfhpple searchWithXPathQuery:@"//input[@name='FORM.TOKEN']"];
                NSArray<TFHppleElement *> *array2 = [tfhpple searchWithXPathQuery:@"//input[@name='token']"];
                self.formToken = [array1[0].attributes objectForKey:@"value"];
                self.token = [array2[0].attributes objectForKey:@"value"];
                [self clickNoOpen];
            }
        });

    }];
    [self.currentTask resume];
}

//自动点不开放
- (void)clickNoOpen
{
    NSString *urlString = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=closeOne&customerId=%@",self.customerId];
    NSString *referer = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=accountDetails&customerId=%@&token=%@",self.customerId,self.token];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    [request addValue:@"https://sales.vemic.com" forHTTPHeaderField:@"Origin"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
    request.HTTPMethod = @"POST";
    
    NSString *string = [NSString stringWithFormat:@"FORM.TOKEN=%@&token=%@",self.formToken,self.token];
    NSMutableData *totalData = [NSMutableData data];
    NSData *parameterData = [string dataUsingEncoding:NSUTF8StringEncoding];
    [totalData appendData:parameterData];
    request.HTTPBody = totalData;
    
    self.currentTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isDevlopping) {
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=closeOne💗💗💗💗💗💗💗💗%@",htmlStr);
                TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
                if (![self presentLogin:tfhpple url:response.URL.absoluteString]) {
                    NSDictionary *dic = [self dictionaryWith:response.URL.absoluteString];
                    NSLog(@"closeoneResultDic💗💗💗💗💗💗💗💗%@",dic);
                    NSLog(@"closeoneResultURL💗💗💗💗💗💗💗💗%@",response.URL.absoluteString);
                    if ([dic objectForKey:@"showMessage"]) {
                        self.successUrlString = response.URL.absoluteString;
                        [self seeResultStepOne];
                    }else if ([htmlStr containsString:@"发生错误"]) {
                        [self showAlertAndRefresh:@"发生错误"];
                    }else if ([htmlStr containsString:@"客户数量已经达到了分公司负责区域限制,不能继续添加客户"]) {
                        [self showAlertAndRefresh:@"客户数量已经达到了分公司负责区域限制,不能继续添加客户"];
                    }else{
                        [self showAlertAndRefresh:@"发生未知错误"];
                    }
                }else{
                    NSLog(@"未登录");
                }
            }else{
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"result2.html" withExtension:nil];
                NSData *data2 = [[NSData alloc] initWithContentsOfURL:url];
                NSString *htmlStr = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
                if ([htmlStr containsString:@"将该客户加为自己的私有客户"]) {
                    NSLog(@"将该客户加为自己的私有客户");
                    [self seeResultStepOne];
                }else if ([htmlStr containsString:@"发生错误"]) {
                    [self showAlertAndRefresh:@"发生错误"];
                }else if ([htmlStr containsString:@"客户数量已经达到了分公司负责区域限制,不能继续添加客户"]) {
                    [self showAlertAndRefresh:@"客户数量已经达到了分公司负责区域限制,不能继续添加客户"];
                }else{
                    [self showAlertAndRefresh:@"发生未知错误"];
                }
            }
        });
    }];
    [self.currentTask resume];
}

//抢客户结果页面
-(void)seeResultStepOne
{
    NSString *urlString = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=accountDetails&customerId=%@&token=%@",self.customerId,self.token];
    NSString *referer  = self.successUrlString;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    self.currentTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertSuccessMessage];
            });

        }
    }];
    [self.currentTask resume];
}

- (void)alertSuccessMessage {
    if (self.customerId && [self.customDict objectForKey:self.customerId]) {
        _hud.label.text = @"盯到啦";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self requesList];
        });
    }else {
        self.sum = self.sum+1;
        self.floatSumLabel.text = [NSString stringWithFormat:@"今日抢客户总数:%ld",_sum];
        [self showAlertAndRefresh:@"将该客户加为自己的私有客户"];
    }
    
}

- (NSDictionary *)dictionaryWith:(NSString *)urlstr
{
    NSURL *url = [NSURL URLWithString:urlstr];
    NSArray *arr = [url.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *temp in arr) {
        NSArray *tempArr = [temp componentsSeparatedByString:@"="];
        if (tempArr.count == 2) {
            NSString *key = tempArr[0];
            NSString *value = tempArr[1];
            [dict setObject:value forKey:key];
        }
    }
    return dict;
}

//- (void)showAlert:(NSString *)text confirm:(void(^)(void))block
//{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:UIAlertControllerStyleAlert];
//    [self.navigationController presentViewController:alert animated:YES completion:nil];
//    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        if (block) {
//            block();
//        }
//    }]];
//}


- (void)showAlertAndRefresh:(NSString *)text
{
    self.resultLabel.text = text;
    [self restartRefreshTimer];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view resignFirstResponder];
}

#pragma mark sessionDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler{
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
    NSLog(@"%ld",urlResponse.statusCode);
    NSLog(@"%@",urlResponse.allHeaderFields);
    
    NSDictionary *dic = urlResponse.allHeaderFields;
    NSLog(@"%@",dic[@"Location"]);
    completionHandler(request);
}

- (BOOL)presentLogin:(TFHpple *)tfhpple url:(NSString *)url {
    TFHppleElement  *titleObj = [[tfhpple searchWithXPathQuery:@"//head/title"] firstObject];
    TFHppleElement  *formObj = [[tfhpple searchWithXPathQuery:@"//form[@id='login_form']"] firstObject];
    NSArray *inputs = [formObj searchWithXPathQuery:@"//input"];
    NSMutableArray *mutableArr = [NSMutableArray array];
    for (TFHppleElement  *titleObj in inputs ) {
        NSString *value = titleObj.attributes[@"value"] ? titleObj.attributes[@"value"]:@"";
        [mutableArr addObject:@{titleObj.attributes[@"name"]:value}];
    }
    if (titleObj && [titleObj.content isEqualToString:@"焦点统一认证系统"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.presentingViewController) {
                loginViewController *loginVC = [[loginViewController alloc] initWithNibName:@"loginViewController" bundle:nil];
                loginVC.formInfo = mutableArr;
                loginVC.requestURLString = url;
                [self.navigationController presentViewController:loginVC animated:YES completion:nil];
            }
        });
        return YES;
    }
    return NO;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    NSLog(@"%@",task.response);
}

#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [swyManage manage].lineHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    customerInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customerInfoCell" forIndexPath:indexPath];
    TFHppleElement *elementAll = _dataSource[indexPath.row];
    NSArray<TFHppleElement *> *array = [elementAll searchWithXPathQuery:@"//td"];//10个数据
    //公司
    TFHppleElement *elemnent1 = [[array[3] searchWithXPathQuery:@"//a"] objectAtIndex:0];
    cell.industoryName.text = elemnent1.content;
    //客户是否注册
    cell.customIDLabel.text = elementAll.hasMicID ? @"已注册":@"未注册";
    if (elementAll.hasKeyWord && elementAll.hasMicID) {//指定公司中的关键字
        cell.customIDLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.industoryName.font = [UIFont boldSystemFontOfSize:15];
        cell.customIDLabel.alpha = 1.0;
        cell.industoryName.alpha = 1.0;
    }else if (!elementAll.hasKeyWord && elementAll.hasMicID){
        cell.customIDLabel.font = [UIFont systemFontOfSize:15];
        cell.industoryName.font = [UIFont systemFontOfSize:15];
        cell.customIDLabel.alpha = 1.0;
        cell.industoryName.alpha = 1.0;
    }else {
        cell.customIDLabel.font = [UIFont systemFontOfSize:15];
        cell.industoryName.font = [UIFont systemFontOfSize:15];
        cell.customIDLabel.alpha = 0.7;
        cell.industoryName.alpha = 0.7;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    TFHppleElement *elementAll = _dataSource[indexPath.row];
    NSArray<TFHppleElement *> *array = [elementAll searchWithXPathQuery:@"//td"];//10个数据
    TFHppleElement *elemnent1 = [[array[3] searchWithXPathQuery:@"//a"] objectAtIndex:0];
    NSString *url = [elemnent1.attributes objectForKey:@"href"];
    [self showRobAcc:[NSString stringWithFormat:@"https://sales.vemic.com%@",url]];
    //request
}

- (BOOL)sortList
{
    //筛选公司
    //1倒序
    if ([swyManage manage].invertSwitch) {
        self.dataSource =(NSMutableArray *)[[self.dataSource reverseObjectEnumerator] allObjects];
    }
//    int randomNum1 = (arc4random() % self.dataSource.count) + 1;
//    int randomNum2 = (arc4random() % self.dataSource.count) + 1;
//    self.dataSource = [self.dataSource subarrayWithRange:NSMakeRange(MIN(randomNum1, randomNum2), abs(randomNum1-randomNum2))];
    
    //2关键字和会员状态排序
    NSArray *words = [[swyManage manage].screenKeyWord componentsSeparatedByString:@"/"];
    NSInteger hasMicCount = 0;
    NSInteger hasKeyWordNOIdCount = 0;
    NSMutableArray *mutableArr = [NSMutableArray array];
    
    for (TFHppleElement  *obj in self.dataSource) {
        NSArray<TFHppleElement *> *array = [obj searchWithXPathQuery:@"//td"];//10个数据
        NSString *industoryName = [array[3] content];
        NSString *micID = [array[2] content];
        obj.hasMicID = micID && ![micID isEqualToString:@"N/A"] ;
        obj.hasKeyWord = [self isHaveString:industoryName inArray:words];
        //盯到客户直接抢 不进行后面的排序
        if ([swyManage manage].settedCustomAutoClickSwitch && obj.hasKeyWord) {
            [self.timer invalidate];
            [self.currentTask suspend];
            TFHppleElement *elemnent1 = [[array[3] searchWithXPathQuery:@"//a"] objectAtIndex:0];
            NSString *urlStr = [elemnent1.attributes objectForKey:@"href"];
            urlStr = [NSString stringWithFormat:@"https://sales.vemic.com%@",urlStr];
            NSDictionary *dic = [self dictionaryWith:urlStr];
            if (dic[@"customerId"]) {
                self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:false];
                self.hud.label.text = [NSString stringWithFormat:@"正在抢:%@",industoryName];
                [swyManage manage].settedCustomAutoClickSwitch = false;
                self.customerId = dic[@"customerId"];
                [self.customDict setObject:industoryName forKey:self.customerId];
                [self showRobAcc:urlStr];
                return YES;
            }
        }
        //排序
        if (obj.hasMicID && [swyManage manage].isRegisterSwitchStatus) {
            if ([swyManage manage].keyWordSwitchStatus && [swyManage manage].screenKeyWord.length && obj.hasKeyWord) {
                [mutableArr insertObject:obj atIndex:0];
                hasMicCount = hasMicCount+1;
            }else {
                [mutableArr insertObject:obj atIndex:hasMicCount];
                hasMicCount = hasMicCount +1;
            }
        }else{
            if ([swyManage manage].keyWordSwitchStatus && [swyManage manage].screenKeyWord.length && obj.hasKeyWord ) {
                [mutableArr insertObject:obj atIndex:hasMicCount+hasKeyWordNOIdCount];
                hasKeyWordNOIdCount = hasKeyWordNOIdCount+1;
            }else {
                [mutableArr addObject:obj];
            }
        }
    }
    self.dataSource = mutableArr;
    return NO;
}

- (bool)isHaveString:(NSString *)string inArray:(NSArray *)array
{
    BOOL flag = false;
    for (NSString *keyWord in array) {
        if ([string containsString:keyWord]) {
            flag = YES;
            continue;
        }
    }
    return flag;
}

@end
