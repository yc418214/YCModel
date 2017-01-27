//
//  YCBaseModel.m
//  YCTestDemo
//
//  Created by 陈煜钏 on 2017/1/19.
//  Copyright © 2017年 陈煜钏. All rights reserved.
//

#import "YCBaseModel.h"

#import <objc/runtime.h>
#import <objc/message.h>
//category
#import "NSDictionary+YCAddition.h"
#import "NSObject+YCAddition.h"

static BOOL YCValidateAndSetValue(id object, NSString *key, id value) {
    __autoreleasing id validatedValue = value;
    @try {
        //validateValue:forKey:error:内部处理可能有三种情况，详见NSObject头文件方法描述
        if (![object validateValue:&validatedValue forKey:key error:NULL]) {
            return NO;
        }
        [object setValue:validatedValue forKey:key];
        return YES;
    } @catch (NSException *exception) {
#if DEBUG
        @throw exception;
#else
        return NO;
#endif
    }
}

@implementation YCBaseModel

#pragma mark - YCModelProtocol

+ (NSDictionary *)JSONKeysDictionary {
    return @{};
}

- (NSArray *)propertiesArrayForCoding {
    return @[];
}

#pragma mark - life cycle

+ (instancetype)modelWithJSONDictionary:(NSDictionary *)JSONDictionary {
    NSDictionary *JSONKeysDictionary = [self JSONKeysDictionaryWithModelClass:[self class]];
    return [self modelWithDictionary:[JSONDictionary yc_modelDictionaryWithJSONKeysDictionary:JSONKeysDictionary]];
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) {
        return nil;
    }
    if (![self configWithDictionary:[dictionary copy]]) {
        return nil;
    }
    return self;
}

#pragma mark - public methods

//执行c函数时传递额外参数
typedef struct {
    void *model;
    void *JSONDictionary;
} YCJSONDictionaryTransformContext;

//转换为JSONDictionary
static void YCJSONDictionaryTransform (const void *key, const void *value, void *context) {
    if (!context) {
        return;
    }
    YCJSONDictionaryTransformContext *JSONDictionaryTransformContext = context;
    id model = (__bridge id)(JSONDictionaryTransformContext->model);
    NSMutableDictionary *JSONDictionary = (__bridge NSMutableDictionary *)(JSONDictionaryTransformContext->JSONDictionary);
    
    NSString *property = (__bridge NSString *)key;
    id JSONValue = [model valueForKey:property];
    if (!JSONValue) {
        return;
    }
    __autoreleasing id transformedJSONValue = JSONValue;
    //子类自定义转换
    if (![model transformValue:&transformedJSONValue forKey:property]) {
        return;
    }
    if (!transformedJSONValue) {
        return;
    }
    Class JSONValueClass = [transformedJSONValue class];
    //如果transformedJSONValue是一个Model
    if ([JSONValueClass cx_isSubclassButNotEqualToClass:[YCBaseModel class]]) {
        transformedJSONValue = [transformedJSONValue JSONDictionary];
    }
    JSONDictionary[(__bridge NSString *)value] = transformedJSONValue;
}

- (NSDictionary *)JSONDictionary {
    Class modelClass = [self class];
    if (![modelClass conformsToProtocol:@protocol(YCModelProtocol)]) {
        return nil;
    }
    NSDictionary *JSONKeysDictionary = [modelClass JSONKeysDictionaryWithModelClass:modelClass];
    NSMutableDictionary *JSONDictionary = [NSMutableDictionary dictionary];
    
    YCJSONDictionaryTransformContext context;
    context.model = (__bridge void*)self;
    context.JSONDictionary = (__bridge void*)JSONDictionary;
    CFDictionaryApplyFunction((CFDictionaryRef)JSONKeysDictionary, YCJSONDictionaryTransform, &context);
    
    return [JSONDictionary copy];
}

- (NSArray *)propertiesNameArray {
    Class modelClass = [self class];
    SEL associateKey = NSSelectorFromString(NSStringFromClass(modelClass));
    NSArray *propertiesNameArray = objc_getAssociatedObject(modelClass, associateKey);
    if (propertiesNameArray) {
        return propertiesNameArray;
    }
    NSMutableArray *propertiesArray = [NSMutableArray array];
    Class class = modelClass;
    while ([class cx_isSubclassButNotEqualToClass:[YCBaseModel class]]) {
        unsigned int propertiesCount = 0;
        objc_property_t *properties = class_copyPropertyList(class, &propertiesCount);
        for (NSInteger i = 0; i < propertiesCount; i++) {
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[i])];
            [propertiesArray addObject:propertyName];
        }
        free(properties);
        class = class_getSuperclass(class);
    }
    propertiesNameArray = [propertiesArray copy];
    objc_setAssociatedObject(modelClass, associateKey, propertiesNameArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return propertiesNameArray;
}

#pragma mark - private methods

- (BOOL)configWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary) {
        return NO;
    }
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    __block BOOL isModelValid = YES;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        id notNullValue = value;
        if ([notNullValue isEqual:[NSNull null]]) {
            notNullValue = nil;
        }
        BOOL isValid = YCValidateAndSetValue(self, key, notNullValue);
        if (!isValid) {
            *stop = YES;
            isModelValid = NO;
        }
    }];
    return isModelValid;
}

+ (NSDictionary *)JSONKeysDictionaryWithModelClass:(Class)modelClass {
    static CFMutableDictionaryRef JSONKeysDictionaryCache;
    static dispatch_semaphore_t semaphore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JSONKeysDictionaryCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(),
                                                            0,
                                                            &kCFTypeDictionaryKeyCallBacks,
                                                            &kCFTypeDictionaryValueCallBacks);
        semaphore = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSDictionary *JSONKeysDictionary = CFDictionaryGetValue(JSONKeysDictionaryCache, (__bridge const void*)modelClass);
    dispatch_semaphore_signal(semaphore);
    
    if (!JSONKeysDictionary) {
        Class class = modelClass;
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        while ([class cx_isSubclassButNotEqualToClass:[YCBaseModel class]]) {
            [dictionary addEntriesFromDictionary:[class JSONKeysDictionary]];
            class = class_getSuperclass(class);
        }
        JSONKeysDictionary = [dictionary copy];
        
        if (JSONKeysDictionary) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(JSONKeysDictionaryCache,
                                 (__bridge void*)modelClass,
                                 (__bridge void*)JSONKeysDictionary);
            dispatch_semaphore_signal(semaphore);
        }
    }
    return JSONKeysDictionary;
}

- (BOOL)transformValue:(id *)value forKey:(NSString *)key {
    if ([self respondsToSelector:@selector(transformForJSONWithValue:forKey:)]) {
        return [self transformForJSONWithValue:value forKey:key];
    }
    NSString *selectorString = [NSString stringWithFormat:@"transformForJSONWith%@:",
                                [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                             withString:[[key substringToIndex:1] capitalizedString]]];
    if ([self respondsToSelector:NSSelectorFromString(selectorString)]) {
        return ((BOOL (*)(id, SEL, id*))objc_msgSend)(self, NSSelectorFromString(selectorString), value);
    }
    return YES;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        NSArray *propertiesArrayForCoding = [self propertiesArrayForCoding];
        for (NSString *property in propertiesArrayForCoding) {
            [self setValue:[aDecoder decodeObjectForKey:property] forKey:property];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSArray *propertiesArrayForCoding = [self propertiesArrayForCoding];
    for (NSString *property in propertiesArrayForCoding) {
        id value = [self valueForKey:property];
        [aCoder encodeObject:value forKey:property];
    }
}

#pragma mark - NSKeyValueCoding

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"%@ undefinedKey : %@", [self class], key);
}

#pragma mark - NSObject

static int i = 0;

- (NSString *)description {
    if (![self respondsToSelector:@selector(propertiesArrayForDescription)]) {
        return [super description];
    }
    i += 2;
    NSMutableString *descriptionString = [NSMutableString stringWithString:@"{ \n"];
    NSArray *propertiesForDescription = [self propertiesArrayForDescription];
    for (NSString *property in propertiesForDescription) {
        id value = [self valueForKey:property];
        
        if ([value isKindOfClass:[NSArray class]]) {
            [descriptionString appendString:[NSString stringWithFormat:@"%*s%@ = ( \n", i, " ", property]];

            [(NSArray *)value enumerateObjectsUsingBlock:^(id valueItem, NSUInteger index, BOOL *stop) {
                [descriptionString appendString:[NSString stringWithFormat:@"%*s%@", i, " ", [valueItem description]]];
                if (index + 1 == ((NSArray *)value).count) {
                    [descriptionString appendString:@" ) \n"];
                } else {
                    [descriptionString appendString:@"\n"];
                }
            }];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            [descriptionString appendString:[NSString stringWithFormat:@"%*s%@ = { \n", i, " ", property]];
            i += 2;
            [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
                [descriptionString appendString:[NSString stringWithFormat:@"%*s%@ = %@ \n", i, " ", key, value]];
            }];
            i -= 2;
            [descriptionString appendString:[NSString stringWithFormat:@"%*s} \n", i, " "]];
        } else {
            [descriptionString appendString:[NSString stringWithFormat:@"%*s%@ = %@ \n", i, " ", property, value]];
        }
    }
    i -= 2;
    if (i != 0) {
        [descriptionString appendString:[NSString stringWithFormat:@"%*s}", i, " "]];
    } else {
        [descriptionString appendString:@"}"];
    }
    return [descriptionString copy];
}

@end
