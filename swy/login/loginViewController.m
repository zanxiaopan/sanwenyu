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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshCode)];
    self.verifyImage.userInteractionEnabled = YES;
    [self.verifyImage addGestureRecognizer:tap];
    [self refreshCode];
    
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

- (void)refreshCode
{
    NSTimeInterval interval = [[NSDate date]timeIntervalSince1970]*1000;
    NSString *urlStr =[NSString stringWithFormat:@"https://sales.vemic.com/validateimage/%.0f.gif",interval];
    NSString *referer = @"https://sales.vemic.com/login_error.do?aut_security_source=SAL";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"GET";
    [request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [request addValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];
    [request addValue:@"zh-CN,zh;q=0.9" forHTTPHeaderField:@"Accept-Language"];
    [request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [request addValue:@"image/webp,image/apng,image/*,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.verifyImage setImage:[UIImage sd_animatedGIFWithData:data]];
                });
    }];
    [task resume];

}

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
    } else if (!_verifyCodeTF.text.length) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"请输入验证码";
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://sales.vemic.com/login.do"]];
    [request configDefaultRequestHeader];
    NSString *refer = @"https://sales.vemic.com/login_error.do?aut_security_source=SAL";
    [request addValue:refer forHTTPHeaderField:@"Referer"];
    [request addValue:@"https://sales.vemic.com" forHTTPHeaderField:@"Origin"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
    request.HTTPMethod = @"POST";
    
    NSString *string = [NSString stringWithFormat:@"aut_security_source=SAL&j_username=%@&j_password=%@&validateNumber=%@&dynPassword=%@",_userNameTF.text,_passwordTF.text,_verifyCodeTF.text,_dynamicCodeTF.text];
    NSMutableData *totalData = [NSMutableData data];
    NSData *parameterData = [string dataUsingEncoding:NSUTF8StringEncoding];
    [totalData appendData:parameterData];
    request.HTTPBody = totalData;
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([response.URL.absoluteString isEqualToString:@"https://sales.vemic.com/workspace.do?aut_security_source=SAL"] || [response.URL.absoluteString isEqualToString:@"http://sales.vemic.com/workspace.do?aut_security_source=SAL"]) {
                [hud hideAnimated:YES afterDelay:0.5];
                [self dismissViewControllerAnimated:YES completion:nil];
                [[swyManage manage] setUserName:self->_userNameTF.text];
                [[swyManage manage] setPassWord:self->_passwordTF.text];
            }else if ([response.URL.absoluteString isEqualToString:@"https://sales.vemic.com/login_error.do?aut_security_source=SAL"]) {
                NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:encoding];
                if ( [htmlStr containsString:@"showHide('echo','用户不存在或密码不正确或用户已被禁用!');"]) {
                    hud.label.text = @"用户不存在或密码不正确或用户已被禁用!";
                    [hud hideAnimated:YES afterDelay:1];
                    [self refreshCode];
                    self.userNameTF.text = nil;
                    self.passwordTF.text = nil;
                    self.verifyCodeTF.text = nil;
                    self.dynamicCodeTF.text = nil;
                }else if ( [htmlStr containsString:@"showHide('echo','验证码输入不正确!');"]){
                    hud.label.text = @"验证码输入不正确!";
                    [hud hideAnimated:YES afterDelay:1];
                    [self refreshCode];
                    self.verifyCodeTF.text = nil;
                    self.dynamicCodeTF.text = nil;
                }else if ( [htmlStr containsString:@"showHide('echo','动态密码不正确');"]){
                    hud.label.text = @"动态密码不正确";
                    [hud hideAnimated:YES afterDelay:1];
                    [self refreshCode];
                    self.verifyCodeTF.text = nil;
                    self.dynamicCodeTF.text = nil;
                }else{
                    hud.label.text = @"登录失败";
                    [hud hideAnimated:YES afterDelay:1];
                    [self refreshCode];
                    self.userNameTF.text = nil;
                    self.passwordTF.text = nil;
                    self.verifyCodeTF.text = nil;
                    self.dynamicCodeTF.text = nil;
                }
            }else{
                hud.label.text = @"登录失败";
                [hud hideAnimated:YES afterDelay:1];
                [self refreshCode];
                self.userNameTF.text = nil;
                self.passwordTF.text = nil;
                self.verifyCodeTF.text = nil;
                self.dynamicCodeTF.text = nil;
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
