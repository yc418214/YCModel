//
//  NSObject+YCAddition.m
//  YCTestDemo
//
//  Created by 陈煜钏 on 2017/1/20.
//  Copyright © 2017年 陈煜钏. All rights reserved.
//

#import "NSObject+YCAddition.h"

@implementation NSObject (YCAddition)

+ (BOOL)cx_isSubclassButNotEqualToClass:(Class)class {
    return [self isSubclassOfClass:class] && self != class;
}

@end
