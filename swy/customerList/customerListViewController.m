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

#define isDevlopping NO

@interface customerListViewController ()<NSURLSessionDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIButton      *refreshBtn;
@property (nonatomic, strong) UIButton      *settingBtn;
@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) NSArray       *dataSource;

@property (nonatomic, strong) NSString          *token;
@property (nonatomic, strong) NSString          *customerId;
@property (nonatomic, strong) NSString          *formToken;
@property (nonatomic, strong) NSURLSession      *session;
@property (nonatomic, strong) MJRefreshStateHeader     *refreshHeader;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation customerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.leftBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:self.refreshBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicator];
    self.title  = @"swy";
    //[self.view addSubview:self.imageView];
    [self.view addSubview:self.tableView];
    self.tableView.mj_header = self.refreshHeader;
    self.imageView.userInteractionEnabled = NO;
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
    [self.indicator startAnimating];
    if (!isDevlopping) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://sales.vemic.com/customer.do?method=listRobAccount"]];
        [request addValue:@"https://sales.vemic.com/customer.do?method=listRobAccount" forHTTPHeaderField:@"Referer"];
        [request configDefaultRequestHeader];
        NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshHeader endRefreshing];
                [self.indicator stopAnimating];
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=listRobAccount💗💗💗💗💗💗💗💗%@",htmlStr);
                if (response && ![response.URL.absoluteString isEqualToString:@"https://sales.vemic.com/login_error.do"]) {
                    TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
                    NSArray *array = [tfhpple searchWithXPathQuery:@"//tr[@class='odd']"];
                    if (array.count) {
                        self.dataSource = array;
                        [self sortList];
                        [self.tableView reloadData];
                    }else{
                        self.dataSource = nil;
                        [self.tableView reloadData];
                        if ([swyManage manage].autoRefreshList) {
                            [self performSelector:@selector(requesList) withObject:nil afterDelay:0.3];
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self.indicator stopAnimating];
        });
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"customerList.html" withExtension:nil];
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *array = [tfhpple searchWithXPathQuery:@"//tr[@class='odd']"];
        if (array.count) {
            self.dataSource = array;
            [self sortList];
            [self.tableView reloadData];
        }
    }

}

//点击某个客户
- (void) showRobAcc:(NSString *)urlStr
{
    self.dataSource = nil;
    [self.tableView reloadData];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *dic = [self dictionaryWith:urlStr];
    if (dic[@"token"] && dic[@"customerId"]) {
        self.token = dic[@"token"];
        self.customerId = dic[@"customerId"];
    }else{
        [self showAlert:@"未获取到token或者customerId" confirm:^{
            [self performSelector:@selector(requesList) withObject:nil afterDelay:0.3];
        }];
        return;
    }
    //showRobAcc
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"https://sales.vemic.com/customer.do?method=listRobAccount" forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isDevlopping) {
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=showRobAcc💗💗💗💗💗💗💗💗%@",htmlStr);
                if (response && ![response.URL.absoluteString isEqualToString:@"https://sales.vemic.com/login_error.do"]) {
                    [self accountDetail];
                }else{
                    NSLog(@"未登录:%@",response.URL.absoluteString);
                }
            }else{
                [self accountDetail];
            }
        });
    }];
    [task resume];
    
}

- (void)accountDetail
{
    NSString *curURLStr  = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=accountDetails&customerId=%@&token=%@",self.customerId,self.token];
    NSString *referer = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=details&customerId=%@&token=%@",self.customerId,self.token];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:curURLStr]];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isDevlopping) {
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=accountDetail💗💗💗💗💗💗💗💗%@",htmlStr);
                if (response && [response.URL.absoluteString isEqualToString:curURLStr]) {
                    TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
                    NSArray<TFHppleElement *> *array = [tfhpple searchWithXPathQuery:@"//input[@name='FORM.TOKEN']"];
                    if (array.count) {
                        self.formToken = [array[0].attributes objectForKey:@"value"];
                        [self clickNoOpen];
                    }else{
                        [self showAlert:@"未取到FORM.TOKEN" confirm:^{
                            [self performSelector:@selector(requesList) withObject:nil afterDelay:0.3];
                        }];
                    }
                }else{
                   NSLog(@"未登录");
                }
            }else{
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"detail.html" withExtension:nil];
                NSData *data2 = [[NSData alloc] initWithContentsOfURL:url];
                TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data2];
                NSArray<TFHppleElement *> *array = [tfhpple searchWithXPathQuery:@"//input[@name='FORM.TOKEN']"];
                self.formToken = [array[0].attributes objectForKey:@"value"];
                [self clickNoOpen];
            }
        });

    }];
    [task resume];
}

//自动点不开放
- (void)clickNoOpen
{
    NSString *urlString = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=closeOne&customerId=%@&FORM.TOKEN=%@&token=%@",self.customerId,self.formToken,self.token];
    NSString *referer = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=accountDetails&customerId=%@&token=%@",self.customerId,self.token];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];

    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isDevlopping) {
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=closeOne💗💗💗💗💗💗💗💗%@",htmlStr);
                if (response && [response.URL.absoluteString isEqualToString:urlString]) {
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
    [task resume];
}

//抢客户结果页面
-(void)seeResultStepOne
{
    NSString *urlString = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=details&token=%@&process=close&customerId=%@",self.token,self.customerId];
    NSString *referer = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=closeOne&customerId=%@&FORM.TOKEN=%@&token=%@",self.customerId,self.formToken,self.token];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response && ![response.URL.absoluteString isEqualToString:@"https://sales.vemic.com/login_error.do"]){
                [self seeResultStepTwo];
            }else{
                [self showAlertAndRefresh:@"将该客户加为自己的私有客户"];
            }
        });
    }];
    [task resume];
}

-(void)seeResultStepTwo
{
    NSString *urlString = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=accountDetails&customerId=%@&token=%@",self.customerId,self.token];
    NSString *referer  = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=details&token=%@&process=close&customerId=%@",self.token,self.customerId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertAndRefresh:@"将该客户加为自己的私有客户"];
        });
    }];
    [task resume];
    
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

- (void)showAlert:(NSString *)text confirm:(void(^)(void))block
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (block) {
            block();
        }
    }]];
}

- (void)showAlertAndRefresh:(NSString *)text
{
    [self showAlert:text confirm:^{
        [self performSelector:@selector(requesList) withObject:nil afterDelay:0.3];
    }];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([dic[@"Location"] isEqualToString:@"https://sales.vemic.com/login_error.do"]) {
            if (!isDevlopping) {
                loginViewController *loginVC = [[loginViewController alloc] initWithNibName:@"loginViewController" bundle:nil];
                [self.navigationController presentViewController:loginVC animated:YES completion:nil];
            }
        }
        completionHandler(request);
    });


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
    //客户编号
    TFHppleElement *elemnent2 = array[1];
    cell.customIDLabel.text = elemnent2.content;
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

- (void)sortList
{
    /*if ([swyManage manage].screenKeyWord.length) {
        NSArray *words = [[swyManage manage].screenKeyWord componentsSeparatedByString:@"/"];
        NSMutableArray *mutableArr = [_dataSource mutableCopy];
        NSMutableArray *mutableArr2 = [_dataSource mutableCopy];
        [mutableArr enumerateObjectsUsingBlock:^(TFHppleElement  *_Nonnull elementAll, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray<TFHppleElement *> *array = [elementAll searchWithXPathQuery:@"//td"];//10个数据
            NSString *industoryName = [array[3] content];;
            if ([self isHaveString:industoryName inArray:words]) {
                TFHppleElement *temp = mutableArr2[0];
                mutableArr2[0] = elementAll;
                mutableArr2[idx] = temp;
            }
        }];
        _dataSource = [NSArray arrayWithArray:mutableArr];
        return;
        
    }*/
    NSArray *words = [[swyManage manage].screenKeyWord componentsSeparatedByString:@"/"];
   self.dataSource =(NSMutableArray *)[[self.dataSource reverseObjectEnumerator] allObjects];
    NSMutableArray *mutableArr = [NSMutableArray array];
    for (TFHppleElement  *obj in self.dataSource) {
        NSArray<TFHppleElement *> *array = [obj searchWithXPathQuery:@"//td"];//10个数据
        NSString *industoryName = [array[3] content];
        if ([self isHaveString:industoryName inArray:words]) {
            [mutableArr insertObject:obj atIndex:0];
        }else{
             [mutableArr addObject:obj];
        }
    }
    self.dataSource = mutableArr;
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
