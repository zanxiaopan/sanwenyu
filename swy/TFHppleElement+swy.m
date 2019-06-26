//
//  TFHppleElement+swy.m
//  swy
//
//  Created by panyuwen on 2019/6/25.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "TFHppleElement+swy.h"
#import <objc/runtime.h>

@implementation TFHppleElement (swy)
//定义常量 必须是C语言字符串
static char *hasKeyWordKey = "hasKeyWord";
static char *isExpectedLastModifyKey = "isExpectedLastModify";
static char *hasMicIDKey = "hasMicID";

-(void)setHasKeyWord:(bool)hasKeyWord{
    
    objc_setAssociatedObject(self, hasKeyWordKey, @(hasKeyWord), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)hasKeyWord{
    return [objc_getAssociatedObject(self, hasKeyWordKey) boolValue];
}

-(void)setIsExpectedLastModify:(BOOL)isExpectedLastModify{
    
    objc_setAssociatedObject(self, isExpectedLastModifyKey, @(isExpectedLastModify), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isExpectedLastModify{
    return [objc_getAssociatedObject(self, isExpectedLastModifyKey) boolValue];
}

-(void)setHasMicID:(BOOL)hasMicID
{
    objc_setAssociatedObject(self, hasMicIDKey, @(hasMicID), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)hasMicID
{
   return [objc_getAssociatedObject(self, hasMicIDKey) boolValue];
}
@end
