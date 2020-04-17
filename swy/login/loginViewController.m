//
//  loginViewController.m
//  swy
//
//  Created by panyuwen on 2019/6/10.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "loginViewController.h"
#import "TFHpple.h"
#import "SDWebImageDownloader.h"
#import "UIImage+GIF.h"
#import "NSMutableURLRequest+header.h"
#import "MBProgressHUD.h"
#import "swyManage.h"
@interface loginViewController ()<NSURLSessionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTF;
@property (weak, nonatomic) IBOutlet UITextField *dynamicCodeTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIImageView *verifyImage;

@property (nonatomic ,strong) NSURLSession *session;

@end

@implementation loginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"登录";
    self.loginBtn.layer.cornerRadius = 5;
    self.loginBtn.layer.masksToBounds = YES;
    self.passwordTF.secureTextEntry = YES;
    [self.loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.userNameTF.text = [swyManage manage].userName;
    if (self.userNameTF.text) {
        self.passwordTF.text = [swyManage manage].passWord;
    }

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.userNameTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.dynamicCodeTF resignFirstResponder];
    [self.verifyCodeTF resignFirstResponder];
}

- (NSURLSession *)session
{
    if (!_session) {
        _session  = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return _session;
}

//- (void)refreshCode
//{
//    NSTimeInterval interval = [[NSDate date]timeIntervalSince1970]*1000;
//    NSString *urlStr =[NSString stringWithFormat:@"https://sales.vemic.com/validateimage/%.0f.gif",interval];
//    NSString *referer = @"https://sales.vemic.com/login_error.do?aut_security_source=SAL";
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
//    request.HTTPMethod = @"GET";
//    [request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
//    [request addValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];
//    [request addValue:@"zh-CN,zh;q=0.9" forHTTPHeaderField:@"Accept-Language"];
//    [request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
//    [request addValue:@"image/webp,image/apng,image/*,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
//    [request addValue:referer forHTTPHeaderField:@"Referer"];
//
//    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.verifyImage setImage:[UIImage sd_animatedGIFWithData:data]];
//                });
//    }];
//    [task resume];
//
//}
//

- (BOOL)localValidate
{
    if (!_userNameTF.text.length) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"请输入用户名";
        [hud hideAnimated:YES afterDelay:1];
        return NO;
    }else if (!_passwordTF.text.length){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"请输入用户密码";
        [hud hideAnimated:YES afterDelay:1];
        return NO;
    }else if(!_dynamicCodeTF.text.length){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"请输入动态码";
        [hud hideAnimated:YES afterDelay:1];
        return NO;
    }
    return YES;
}


- (void)loginAction
{
    if (![self localValidate]) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestURLString]];
    [request configDefaultRequestHeader];
    NSString *refer = @"https://sales.vemic.com/login_error.do?aut_security_source=SAL";
    [request addValue:refer forHTTPHeaderField:@"Referer"];
    [request addValue:@"https://sales.vemic.com" forHTTPHeaderField:@"Origin"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
    request.HTTPMethod = @"POST";
    //account=dongwei&password=112233&mickey=223321&logincli=1&mickstatus=1
    NSMutableString *mutableString = [NSMutableString string];
    for (NSInteger i=0; i<_formInfo.count; i++) {
        NSString *key = [_formInfo[i] allKeys].firstObject;
        NSString *value = _formInfo[i][key];
        if ([key isEqualToString:@"account"]) {
            value = _userNameTF.text;
        }else if ([key isEqualToString:@"password"]) {
            value = _passwordTF.text;
        }else if ([key isEqualToString:@"mickey"]) {
            value = _dynamicCodeTF.text;
        }
        if (i == 0) {
            [mutableString appendFormat:@"%@=%@",key,value];
        }else {
            [mutableString appendFormat:@"&%@=%@",key,value];
        }
    }
    NSMutableData *totalData = [NSMutableData data];
    NSData *parameterData = [mutableString dataUsingEncoding:NSUTF8StringEncoding];
    [totalData appendData:parameterData];
    request.HTTPBody = totalData;
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *htmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"loginResponse💗💗💗💗💗💗💗💗%@",htmlStr);
            TFHpple *tfhpple = [[TFHpple alloc] initWithHTMLData:data];
            TFHppleElement  *titleObj = [[tfhpple searchWithXPathQuery:@"//head/title"] firstObject];
            TFHppleElement  *loginErrorObj = [[tfhpple searchWithXPathQuery:@"//div[@id='login_error']"] firstObject];
            //login_error
            if (loginErrorObj) {
                TFHppleElement  *loginErrorMessageObj = [[loginErrorObj searchWithXPathQuery:@"//div"]firstObject];
                NSString *errorMessage =  [loginErrorMessageObj.content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                hud.label.text = loginErrorMessageObj ? errorMessage : @"登录失败";
                [hud hideAnimated:YES afterDelay:1];
                self.dynamicCodeTF.text = nil;
            }else if (titleObj && [titleObj.content isEqualToString:@""]){
                hud.label.text =  @"登录失败";
                [hud hideAnimated:YES afterDelay:1];
                self.dynamicCodeTF.text = nil;
            }else {
                [hud hideAnimated:YES afterDelay:0.5];
                [self dismissViewControllerAnimated:YES completion:nil];
                [[swyManage manage] setUserName:self->_userNameTF.text];
                [[swyManage manage] setPassWord:self->_passwordTF.text];
            }
        });
    }];
    [task resume];
}

- (NSDictionary *)httpHeadDic
{
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    return mutableDic;

}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler;
{
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
    NSLog(@"%ld",urlResponse.statusCode);
    NSLog(@"%@",urlResponse.allHeaderFields);
    NSDictionary *dic = urlResponse.allHeaderFields;
    NSLog(@"%@",dic[@"Location"]);
    if (dic[@"Location"] && [dic[@"Location"] isEqualToString:@""]) {
        
    }
    completionHandler(request);
}

@end
