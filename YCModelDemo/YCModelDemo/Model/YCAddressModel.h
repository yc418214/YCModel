//
//  YCAddressModel.h
//  YCTestDemo
//
//  Created by 陈煜钏 on 2017/1/20.
//  Copyright © 2017年 陈煜钏. All rights reserved.
//

#import "YCBaseModel.h"

@interface YCAddressModel : YCBaseModel <YCModelProtocol>

@property (copy, nonatomic) NSString *provinceString;

@property (copy, nonatomic) NSString *cityString;

@end
