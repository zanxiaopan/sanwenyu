//
//  loginViewController.h
//  swy
//
//  Created by panyuwen on 2019/6/10.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface loginViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *formInfo;
@property (nonatomic, copy) NSString *requestURLString;
@end

NS_ASSUME_NONNULL_END
