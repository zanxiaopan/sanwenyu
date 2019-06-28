//
//  swyManage.m
//  swy
//
//  Created by panyuwen on 2019/6/19.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "swyManage.h"
@interface swyManage ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end
@implementation swyManage

+ (swyManage *)manage {
    static dispatch_once_t once;
    static swyManage *swyManger;
    dispatch_once(&once, ^{
        swyManger = [[self alloc] init];
    });
    return swyManger;
}

- (NSInteger)lineHeight
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"lineHeight"];
    if (number) {
        return [number integerValue];
    }else{
        return 30;
    }
}

- (void)setLineHeight:(NSInteger)lineHeight
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:lineHeight] forKey:@"lineHeight"];

}

- (NSString *)userName
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"j_username"];
    if (userName) {
        return userName;
    }else{
        return @"gaoshan";
    }
}

- (void)setUserName:(NSString *)userName
{
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"j_username"];
}

- (NSString *)passWord
{
    NSString *passWord = [[NSUserDefaults standardUserDefaults] objectForKey:@"j_password"];
    if (passWord) {
        return passWord;
    }else{
        return @"";
    }
}

- (void)setPassWord:(NSString *)passWord
{
    [[NSUserDefaults standardUserDefaults] setObject:passWord forKey:@"j_password"];
}

- (BOOL)isBirthDay
{
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    if ([dateString isEqualToString:@"2019-06-21"]) {
        return YES;
    }
    return NO;
}

-(BOOL)autoRefreshList
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"autoRefreshList"]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"autoRefreshList"]boolValue];
    }else{
        return YES;
    }
}

- (void)setAutoRefreshList:(BOOL)autoRefreshList
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:autoRefreshList] forKey:@"autoRefreshList"];
}

- (void)setScreenKeyWord:(NSString *)screenKeyWord
{
     [[NSUserDefaults standardUserDefaults] setObject:screenKeyWord forKey:@"screenKeyWord"];
}

- (NSString *)screenKeyWord
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"screenKeyWord"]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"screenKeyWord"];
    }else{
        return @"";
    }
}

- (void)setSortWordLastModifyPerson:(NSString *)sortWordLastModifyPerson
{
    [[NSUserDefaults standardUserDefaults] setObject:sortWordLastModifyPerson forKey:@"sortWordLastModifyPerson"];
}

- (NSString *)sortWordLastModifyPerson
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"sortWordLastModifyPerson"]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"sortWordLastModifyPerson"];
    }else{
        return @"";
    }
}

- (void)setKeyWordSwitchStatus:(BOOL)keyWordSwitchStatus
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:keyWordSwitchStatus] forKey:@"keyWordSwitchStatus"];
}

- (BOOL)keyWordSwitchStatus
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"keyWordSwitchStatus"]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"keyWordSwitchStatus"]boolValue];
    }else{
        return NO;
    }
}

- (void)setIsRegisterSwitchStatus:(BOOL)isRegisterSwitchStatus
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isRegisterSwitchStatus] forKey:@"isRegisterSwitchStatus"];
}

- (BOOL)isRegisterSwitchStatus
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isRegisterSwitchStatus"]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"isRegisterSwitchStatus"]boolValue];
    }else{
        return NO;
    }
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _dateFormatter;
}

- (void)setCookie:(NSMutableURLRequest *)request
{
    // 创建可变字典用于存放Cookie
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    
    NSMutableString *cookieValue = [[NSMutableString alloc] init];
    // 获取
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        if ([cookie.domain isEqualToString:@"sales.vemic.com"]) {
            [cookieDic setObject:cookie.value forKey:cookie.name];
        }
    }
    // cookie重复，先放到字典去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    [request addValue:cookieValue forHTTPHeaderField:@"Cookie"];
}

@end
