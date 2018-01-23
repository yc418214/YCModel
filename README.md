# YCModel
封装一个简单的model基类

<p>

### 过程：

[从0到1造一个Model](https://github.com/yc418214/Article/tree/master/Model)

### 使用实例：

#### 实例化：
````

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
    YCUserModel *userModel = [YCUserModel modelWithJSONDictionary:JSONDictionary];


````

<p>

#### 逆转换：

````
    NSLog("JSONDictionary : %@", [userModel JSONDictionary]);
````

##### 结果：

````
2017-01-27 12:14:58.369 YCModelDemo[58735:2148615] JSONDictionary : {
    address =     {
        city = guangzhou;
        province = Guangdong;
    };
    age = 23;
    birthday = "1485490498.358339";
    friends =     (
                {
            age = 20;
            name = a;
        },
                {
            age = 21;
            name = b;
        }
    );
    name = yuchuan;
    score =     {
        english = 100;
        math = 100;
    };
}
````

<p>

#### Description：
````
    NSLog(@"model : %@", userModel);
````

##### 结果：

````
2017-01-27 12:14:58.369 YCModelDemo[58735:2148615] userModel : { 
  userName = yuchuan 
  userAge = 23 
  birthdayDate = 2017-01-27 04:14:58 +0000 
  userScoreDictionary = { 
    english = 100 
    math = 100 
  } 
  userAddress = { 
    provinceString = Guangdong 
    cityString = guangzhou 
  } 
  friendsArray = ( 
  { 
    userName = a 
    userAge = 20 
    birthdayDate = (null) 
    userScoreDictionary = (null) 
    userAddress = (null) 
    friendsArray = (null) 
  }
  { 
    userName = b 
    userAge = 21 
    birthdayDate = (null) 
    userScoreDictionary = (null) 
    userAddress = (null) 
    friendsArray = (null) 
  } ) 
}
````
