//
//  YCUserModel.h
//  YCTestDemo
//
//  Created by 陈煜钏 on 2017/1/19.
//  Copyright © 2017年 陈煜钏. All rights reserved.
//

#import "YCBaseModel.h"

#import "YCAddressModel.h"

@interface YCUserModel : YCBaseModel <YCModelProtocol>

@property (copy, nonatomic) NSString *userName;

@property (assign, nonatomic) NSInteger userAge;

@property (strong, nonatomic) NSDate *birthdayDate;

@property (copy, nonatomic) NSDictionary *userScoreDictionary;

@property (strong, nonatomic) YCAddressModel *userAddress;

@property (copy, nonatomic) NSArray<YCUserModel *> *friendsArray;

@end
