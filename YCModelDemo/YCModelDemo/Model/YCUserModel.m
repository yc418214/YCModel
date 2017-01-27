//
//  YCUserModel.m
//  YCTestDemo
//
//  Created by 陈煜钏 on 2017/1/19.
//  Copyright © 2017年 陈煜钏. All rights reserved.
//

#import "YCUserModel.h"

@implementation YCUserModel

#pragma mark - YCModelProtocol

+ (NSDictionary *)JSONKeysDictionary {
    return @{ NSStringFromSelector(@selector(userName)) : @"name",
              NSStringFromSelector(@selector(userAge)) : @"age",
              NSStringFromSelector(@selector(birthdayDate)) : @"birthday",
              NSStringFromSelector(@selector(userAddress)) : @"address",
              NSStringFromSelector(@selector(friendsArray)) : @"friends",
              NSStringFromSelector(@selector(userScoreDictionary)) : @"score" };
}

- (NSArray *)propertiesArrayForCoding {
    return [self propertiesNameArray];
}

- (NSArray *)propertiesArrayForDescription {
    return [self propertiesNameArray];
}

#pragma mark - KVV

- (BOOL)validateBirthdayDate:(inout id  _Nullable __autoreleasing *)value error:(out NSError * _Nullable __autoreleasing *)outError {
    if (!*value) {
        return YES;
    }
    if (![*value isKindOfClass:[NSString class]]) {
        return NO;
    }
    *value = [NSDate dateWithTimeIntervalSince1970:((NSString *)*value).doubleValue];
    return YES;
}

- (BOOL)validateUserAddress:(inout id  _Nullable __autoreleasing *)value error:(out NSError * _Nullable __autoreleasing *)outError {
    if (!*value) {
        return YES;
    }
    if (![*value isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    *value = [YCAddressModel modelWithJSONDictionary:*value];
    return YES;
}

- (BOOL)validateFriendsArray:(inout id  _Nullable __autoreleasing *)value error:(out NSError * _Nullable __autoreleasing *)outError {
    if (!*value) {
        return YES;
    }
    if (![*value isKindOfClass:[NSArray class]]) {
        return NO;
    }
    NSMutableArray *friendModelsArray = [NSMutableArray array];
    for (NSDictionary *JSONDictionary in (NSArray *)*value) {
        YCUserModel *friendModel = [YCUserModel modelWithJSONDictionary:JSONDictionary];
        if (friendModel) {
            [friendModelsArray addObject:friendModel];
        }
    }
    *value = [friendModelsArray copy];
    return YES;
}

#pragma mark - Transform for JSON

- (BOOL)transformForJSONWithBirthdayDate:(__autoreleasing id *)value {
    if (![*value isKindOfClass:[NSDate class]]) {
        return NO;
    }
    NSDate *timestamp = (NSDate *)*value;
    *value = @([timestamp timeIntervalSince1970]).stringValue;
    return YES;
}

- (BOOL)transformForJSONWithFriendsArray:(__autoreleasing id *)value {
    if (![*value isKindOfClass:[NSArray class]]) {
        return NO;
    }
    NSMutableArray *friendsJSONArray = [NSMutableArray array];
    for (YCUserModel *friendModel in (NSArray *)*value) {
        NSDictionary *JSONDictionary = [friendModel JSONDictionary];
        if (JSONDictionary) {
            [friendsJSONArray addObject:JSONDictionary];
        }
    }
    *value = [friendsJSONArray copy];
    return YES;
}

@end
