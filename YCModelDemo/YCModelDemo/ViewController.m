//
//  ViewController.m
//  YCModelDemo
//
//  Created by 陈煜钏 on 2017/1/27.
//  Copyright © 2017年 陈煜钏. All rights reserved.
//

#import "ViewController.h"

#import "YCUserModel.h"

@interface ViewController ()

@property (strong, nonatomic) YCUserModel *userModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *timestampString = @([[NSDate date] timeIntervalSince1970]).stringValue;
    NSDictionary *JSONDictionary = @{ @"name" : @"yuchuan",
                                      @"age" : @(23),
                                      @"birthday" : timestampString,
                                      @"friends" : @[ @{ @"name" : @"a",
                                                         @"age" : @(20) },
                                                      @{ @"name" : @"b",
                                                         @"age" : @(21) }],
                                      @"address" : @{ @"province" : @"Guangdong",
                                                      @"city" : @"guangzhou"},
                                      @"score" : @{ @"english" : @(100),
                                                    @"math" : @(100) } };
    self.userModel = [YCUserModel modelWithJSONDictionary:JSONDictionary];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"userModel : %@", self.userModel);
    NSLog(@"JSONDictionary : %@", [self.userModel JSONDictionary]);
}

@end
