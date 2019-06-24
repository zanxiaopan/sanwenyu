//
//  backArrow.m
//  swy
//
//  Created by panyuwen on 2019/6/18.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "backArrow.h"

@implementation backArrow

- (void)drawRect:(CGRect)rect {
    // 1.获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, rect.size.width, 0);
    CGContextAddLineToPoint(ctx, 0, rect.size.height/2);
    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height);
    [[UIColor orangeColor] set];
    CGContextSetLineWidth(ctx, 2.0f); // 线的宽度
    CGContextSetLineCap(ctx, kCGLineCapRound); // 起点和重点圆角
    CGContextSetLineJoin(ctx, kCGLineJoinRound); // 转角圆角
    CGContextStrokePath(ctx);
}


@end
