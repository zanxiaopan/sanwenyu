//
//  NSMutableURLRequest+header.m
//  swy
//
//  Created by panyuwen on 2019/6/12.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "NSMutableURLRequest+header.h"

@implementation NSMutableURLRequest (header)

- (void)configDefaultRequestHeader
{
    self.HTTPMethod = @"GET";
    [self addValue:@"1" forHTTPHeaderField:@"Upgrade-Insecure-Requests"];
    [self addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [self addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3" forHTTPHeaderField:@"Accept"];
    [self addValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [self addValue:@"zh-CN,zh;q=0.9" forHTTPHeaderField:@"Accept-Language"];
    [self addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];

}

@end
