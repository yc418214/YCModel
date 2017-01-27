//
//  YCModelProtocol.h
//  YCTestDemo
//
//  Created by 陈煜钏 on 2017/1/19.
//  Copyright © 2017年 陈煜钏. All rights reserved.
//

@protocol YCModelProtocol

@required
+ (NSDictionary *)JSONKeysDictionary;
//需要归档的属性数组
- (NSArray *)propertiesArrayForCoding;

@optional
//调试查看的属性数组
- (NSArray *)propertiesArrayForDescription;
//自定义转换为JSON数据
- (BOOL)transformForJSONWithValue:(id *)value forKey:(NSString *)key;

@end
