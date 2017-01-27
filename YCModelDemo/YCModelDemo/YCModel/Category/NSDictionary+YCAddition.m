//
//  NSDictionary+YCAddition.m
//  YCTestDemo
//
//  Created by 陈煜钏 on 2017/1/19.
//  Copyright © 2017年 陈煜钏. All rights reserved.
//

#import "NSDictionary+YCAddition.h"

#import "YCModelProtocol.h"

@class YCBaseModel;

typedef struct {
    void *JSONDictionary;
    void *modelDictionary;
} YCDictionaryFunctionContext;

static void YCModelDictionaryConfiguration(const void *key, const void *value, void *context) {
    if (!context) {
        return;
    }
    YCDictionaryFunctionContext *functionContext = context;
    NSDictionary *JSONDictionary = (__bridge NSDictionary*)(functionContext->JSONDictionary);
    NSMutableDictionary *modelDictionary = (__bridge NSMutableDictionary*)(functionContext->modelDictionary);
    
    NSArray *JSONKeysArray = [((__bridge NSString *)value) componentsSeparatedByString:@"."];
    id JSONValue = JSONDictionary;
    for (NSString *JSONKey in JSONKeysArray) {
        if (![JSONValue isKindOfClass:[NSDictionary class]]) {
            break;
        }
        JSONValue = JSONValue[JSONKey];
    }
    modelDictionary[(__bridge id)key] = JSONValue;
}

@implementation NSDictionary (YCAddition)

#pragma mark - public methods

- (NSDictionary *)yc_modelDictionaryWithJSONKeysDictionary:(NSDictionary *)JSONKeysDictionary {
    NSMutableDictionary *modelDictionary = [NSMutableDictionary dictionary];
    
    YCDictionaryFunctionContext context;
    context.JSONDictionary = (__bridge void*)self;
    context.modelDictionary = (__bridge void*)modelDictionary;
    
    CFDictionaryApplyFunction((CFDictionaryRef)JSONKeysDictionary, YCModelDictionaryConfiguration, &context);
    
    return [modelDictionary copy];
}

@end
