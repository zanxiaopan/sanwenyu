//
//  newRigisterCustomListVC.m
//  swy
//
//  Created by panyuwen on 2019/8/20.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "newRigisterCustomListVC.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import "TFHpple.h"
#import "swyManage.h"
#import "NSMutableURLRequest+header.h"
#import "customerInfoCell.h"
#import "TFHppleElement+swy.h"
#import "loginViewController.h"


@interface newRigisterCustomListVC ()<NSURLSessionDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;;
@property (nonatomic, strong) NSArray       *dataSource;
@property (nonatomic, strong) NSURLSession      *session;
@property (nonatomic, strong) NSString          *token;
@property (nonatomic, strong) NSString          *customerId;
@property (nonatomic, strong) NSString          *formToken;
@property (nonatomic, strong) NSString          *requestListURLString;
@property (nonatomic, strong) NSString          *detailURLString;
@property (nonatomic, strong) MJRefreshStateHeader     *refreshHeader;
@end

@implementation newRigisterCustomListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicator];
    [self.view addSubview:self.tableView];
    self.tableView.mj_header = self.refreshHeader;
    self.title = @"我的区域的开放客户";
    
    NSString *dateStr = [self dateString];
    NSString *urlString = @"http://sales.vemic.com/uitoolList.ui?orderField=&orderOper=&uplike=0&pageLimit=20&s_f=&o_f=&d_f=&gotoUrl=customer.do%3Fmethod%3DoperateView&isOpen=1&funcID=1000931&ACCOUNT_ID=&searchOper=%3D&TEMP_MIC_ID=&searchOper=%3D&ACCOUNT_NAME=&searchOper=like&ACCOUNT_LEVEL=&searchOper=%3D&HOMEPAGE=&searchOper=like&TELEPHONE=&searchOper=like&FULLNAME2=&searchOper=like&S_MODIFIED_TIME2=";// system 或者刘海燕
    urlString = [urlString stringByAppendingString:dateStr];
    urlString = [urlString stringByAppendingString:@"&E_MODIFIED_TIME2="];
    urlString = [urlString stringByAppendingString:dateStr];
    urlString = [urlString stringByAppendingString:@"&searchOper=%3E%3D&searchOper=%3C%3D&FULLNAME1=system&searchOper=like&ADDRESS=&searchOper=like&CITY=&searchOper=like&CITYZONE=&searchOper=like&S_KEEP_DAYS=&E_KEEP_DAYS=&searchOper=%3E%3D&searchOper=%3C%3D&HAS_MIC_ID=&searchOper=%3D&AREA_CITY=&searchOper=%3D"];
    self.requestListURLString = urlString;
    
    [self requesList];
    
    
}

- (NSURLSession *)session
{
    if (!_session) {
        _session  = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return _session;
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

#pragma mark Action
- (void)requesList
{
    [self.indicator startAnimating];
    if (!isDevlopping) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestListURLString]];
        [request addValue:@"http://sales.vemic.com/uitoolList.ui?funcID=1000931&gotoUrl=customer.do?method=operateView&isOpen=1" forHTTPHeaderField:@"Referer"];
        [request configDefaultRequestHeader];
        NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshHeader endRefreshing];
                [self.indicator stopAnimating];
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=operateView💗💗💗💗💗💗💗💗%@",htmlStr);
                if (response && ![response.URL.absoluteString isEqualToString:@"https://sales.vemic.com/login_error.do"]) {
                    TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
                    NSArray *array = [tfhpple searchWithXPathQuery:@"//tr[@id='data_tr']"];
                    array = [self filterArr:array];
                    if (array.count) {
                        self.dataSource = array;
                        [self.tableView reloadData];
                    }else{
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
        [self.indicator startAnimating];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.indicator stopAnimating];
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"newCustomList.html" withExtension:nil];
            NSData *data = [[NSData alloc] initWithContentsOfURL:url];
            TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
            NSArray *array = [tfhpple searchWithXPathQuery:@"//tr[@id='data_tr']"];
            array = [self filterArr:array];
            if (array.count) {
                self.dataSource = array;
                [self.tableView reloadData];
            }else{
                if ([swyManage manage].autoRefreshList) {
                    [self performSelector:@selector(requesList) withObject:nil afterDelay:0.3];
                }
            }
        });

    }
}


- (void)showRobAcc:(NSString *)urlStr
{
    self.dataSource = nil;
    [self.tableView reloadData];
    self.detailURLString = urlStr;
    //showRobAcc
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request addValue:self.requestListURLString forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isDevlopping) {
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=showRobAcc💗💗💗💗💗💗💗💗%@",htmlStr);
                if (!error && response && ![response.URL.absoluteString isEqualToString:@"https://sales.vemic.com/login_error.do"]) {
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

- (void)accountDetail {
    NSString *curURLStr  = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=accountDetails&customerId=%@&token=",self.customerId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:curURLStr]];
    [request addValue:self.detailURLString forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isDevlopping) {
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=accountDetail💗💗💗💗💗💗💗💗%@",htmlStr);
                if (!error && response && [response.URL.absoluteString isEqualToString:curURLStr]) {
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
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"newDetail.html" withExtension:nil];
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

- (void)clickNoOpen {
    NSString *urlString = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=closeOne&customerId=%@&FORM.TOKEN=%@",self.customerId,self.formToken];
    NSString *referer = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=accountDetails&customerId=%@&token=",self.customerId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isDevlopping) {
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                NSLog(@"method=closeOne💗💗💗💗💗💗💗💗%@",htmlStr);
                if (!error && response && [response.URL.absoluteString isEqualToString:urlString]) {
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
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"newResult.html" withExtension:nil];
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
    NSString *urlString = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=details&token=null&process=close&customerId=%@",self.customerId];
    NSString *referer = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=closeOne&customerId=%@&FORM.TOKEN=%@",self.customerId,self.formToken];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && response && ![response.URL.absoluteString isEqualToString:@"https://sales.vemic.com/login_error.do"]){
                [self seeResultStepTwo];
            }else{
                [self showAlertAndRefresh:@"将该客户加为自己的私有客户"];;
            }
        });
    }];
    [task resume];
}

-(void)seeResultStepTwo
{
    NSString *urlString = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=accountDetails&customerId=%@&token=null",self.customerId];
    NSString *referer  = [NSString stringWithFormat:@"https://sales.vemic.com/customer.do?method=details&token=null&process=close&customerId=%@",self.customerId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    [request configDefaultRequestHeader];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
               [self showAlertAndRefresh:@"将该客户加为自己的私有客户"];
            });
        }
    }];
    [task resume];
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
        [self requesList];
    }];
}



- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)filterArr:(NSArray *)arr {
    NSMutableArray *temp = [NSMutableArray array];
    for (TFHppleElement *element in arr) {
        NSArray<TFHppleElement *> *array = [element searchWithXPathQuery:@"//td"];//10个数据
        TFHppleElement *elemnent1 = [[array[13] searchWithXPathQuery:@"//a"] objectAtIndex:0];
        NSString *url = [elemnent1.attributes objectForKey:@"href"];
        ///customer.do?method=details&customerId=&otherFields=%26E_MODIFIED_TIME2=2019-08-22%26d_f=%26ACCOUNT_ID=%26gotoUrl=customer.do?method=operateView%26isOpen=1%26ADDRESS=%26o_f=%26FULLNAME1=system%26FULLNAME2=%26CITYZONE=%26s_f=%26HAS_MIC_ID=%26E_KEEP_DAYS=%26AREA_CITY=%26searchOper==%26searchOper==%26searchOper=like%26searchOper==%26searchOper=like%26searchOper=like%26searchOper=like%26searchOper=>=%26searchOper=<=%26searchOper=like%26searchOper=like%26searchOper=like%26searchOper=like%26searchOper=>=%26searchOper=<=%26searchOper==%26searchOper==%26funcID=1000931%26TELEPHONE=%26S_KEEP_DAYS=%26CITY=%26HOMEPAGE=%26uplike=0%26ACCOUNT_LEVEL=%26S_MODIFIED_TIME2=2019-08-22%26ACCOUNT_NAME=%26TEMP_MIC_ID=
        NSString *queryString = [url substringWithRange:NSMakeRange(13, url.length-13)];
        NSDictionary *params = [self dictionaryWith:queryString];
        if ([[params objectForKey:@"customerId"] length]) {
            [temp addObject:element];
            element.customerId = [params objectForKey:@"customerId"];
        }
    }
    return [NSArray arrayWithArray:temp];
}

- (NSDictionary *)dictionaryWith:(NSString *)queryString
{
    NSArray *arr = [queryString componentsSeparatedByString:@"&"];
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

- (NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    return [formatter stringFromDate:[NSDate date]];
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
    TFHppleElement *elemnent1 = [[array[4] searchWithXPathQuery:@"//a"] objectAtIndex:0];
    cell.industoryName.text = elemnent1.content;
    //会员编号
    TFHppleElement *elemnent2 = [[array[3] searchWithXPathQuery:@"//a"] objectAtIndex:0];
    cell.customIDLabel.text = elemnent2.content;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    TFHppleElement *elementAll = _dataSource[indexPath.row];
    NSArray<TFHppleElement *> *array = [elementAll searchWithXPathQuery:@"//td"];//10个数据
    TFHppleElement *elemnent1 = [[array[13] searchWithXPathQuery:@"//a"] objectAtIndex:0];
    NSString *url = [elemnent1.attributes objectForKey:@"href"];
    self.customerId = elementAll.customerId;
    [self showRobAcc:[NSString stringWithFormat:@"https://sales.vemic.com%@",url]];
    //request
}





@end
