//
//  NSMutableArray+NotNull.m
//  Account
//
//  Created by 陈亚飞 on 2017/7/26.
//  Copyright © 2017年 陈亚飞. All rights reserved.
//

#import "NSMutableArray+NotNull.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSMutableArray (NotNull)

+(void)load
{
    Method orginaMethod = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(addObject:));
    Method newMethod = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(gp_addObject:));
    method_exchangeImplementations(orginaMethod, newMethod);
}

-(void)gp_addObject:(id)object
{
    if (object!=nil)
    {
        [self gp_addObject:object];
    }else
    {
        NSLog(@"内容为空");
    }
}

@end
