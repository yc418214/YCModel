//
//  YCAddressModel.m
//  YCTestDemo
//
//  Created by 陈煜钏 on 2017/1/20.
//  Copyright © 2017年 陈煜钏. All rights reserved.
//

#import "YCAddressModel.h"

@implementation YCAddressModel

#pragma mark - YCModelProtocol

+ (NSDictionary *)JSONKeysDictionary {
    return @{ NSStringFromSelector(@selector(provinceString)) : @"province",
              NSStringFromSelector(@selector(cityString)) : @"city" };
}

- (NSArray *)propertiesArrayForDescription {
    return [self propertiesNameArray];
}

- (NSArray *)propertiesArrayForCoding {
    return [self propertiesNameArray];
}



@end
