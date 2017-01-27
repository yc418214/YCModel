//
//  YCBaseModel.h
//  YCTestDemo
//
//  Created by 陈煜钏 on 2017/1/19.
//  Copyright © 2017年 陈煜钏. All rights reserved.
//

#import <Foundation/Foundation.h>

//protocol
#import "YCModelProtocol.h"

@interface YCBaseModel : NSObject <YCModelProtocol, NSCoding>

+ (instancetype)modelWithJSONDictionary:(NSDictionary *)JSONDictionary;

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)JSONDictionary;

- (NSArray *)propertiesNameArray;

@end
