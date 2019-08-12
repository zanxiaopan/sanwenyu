//
//  launchViewController.m
//  swy
//
//  Created by panyuwen on 2019/6/12.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "launchViewController.h"
#import "swyManage.h"

@interface launchViewController ()

@end

@implementation launchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    if ([swyManage manage].launchImage) {
        imageView.image = [swyManage manage].launchImage;
    }else {
        imageView.image = [UIImage imageNamed:@"IMG_61332.JPG"];
    }
    [self.view addSubview:imageView];
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        
    }];
    
}



@end
