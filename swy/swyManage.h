//
//  swyManage.h
//  swy
//
//  Created by panyuwen on 2019/6/19.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDrawerController.h"
NS_ASSUME_NONNULL_BEGIN

@interface swyManage : NSObject
+ (swyManage *)manage;
@property (nonatomic ,copy) NSString *userName;
@property (nonatomic ,copy) NSString *passWord;
@property (nonatomic ,assign) NSInteger lineHeight;
@property (nonatomic ,assign) BOOL isBirthDay;
@property (nonatomic ,assign) BOOL autoRefreshList;
@property (nonatomic ,assign) BOOL keyWordSwitchStatus;
@property (nonatomic ,assign) BOOL isRegisterSwitchStatus;

@property (nonatomic ,copy) NSString *screenKeyWord;
@property (nonatomic ,copy) NSString *sortWordLastModifyPerson;

@property (strong, nonatomic) MMDrawerController *drawerController;
@end

NS_ASSUME_NONNULL_END
