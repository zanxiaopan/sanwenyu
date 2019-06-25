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

-(void)setHasKeyWord:(bool)hasKeyWord{
    /*
     OBJC_ASSOCIATION_ASSIGN;            //assign策略
     OBJC_ASSOCIATION_RETAIN_NONATOMIC;  // retain策略
     OBJC_ASSOCIATION_COPY_NONATOMIC;    //copy策略
     
     OBJC_ASSOCIATION_RETAIN;
     OBJC_ASSOCIATION_COPY;
     */
    /*
     * id object 给哪个对象的属性赋值
     const void *key 属性对应的key
     id value  设置属性值为value
     objc_AssociationPolicy policy  使用的策略，是一个枚举值，和copy，retain，assign是一样的，手机开发一般都选择NONATOMIC
     objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
     */
    
    objc_setAssociatedObject(self, hasKeyWordKey, @(hasKeyWord), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)hasKeyWord{
    return objc_getAssociatedObject(self, hasKeyWordKey);
}

-(void)setIsExpectedLastModify:(BOOL)isExpectedLastModify{
    /*
     OBJC_ASSOCIATION_ASSIGN;            //assign策略
     OBJC_ASSOCIATION_RETAIN_NONATOMIC;  // retain策略
     OBJC_ASSOCIATION_COPY_NONATOMIC;    //copy策略
     
     OBJC_ASSOCIATION_RETAIN;
     OBJC_ASSOCIATION_COPY;
     */
    /*
     * id object 给哪个对象的属性赋值
     const void *key 属性对应的key
     id value  设置属性值为value
     objc_AssociationPolicy policy  使用的策略，是一个枚举值，和copy，retain，assign是一样的，手机开发一般都选择NONATOMIC
     objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
     */
    
    objc_setAssociatedObject(self, isExpectedLastModifyKey, @(isExpectedLastModify), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isExpectedLastModify{
    return objc_getAssociatedObject(self, isExpectedLastModifyKey);
}
@end
