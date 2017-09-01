
//
//  PK-ios
//
//  Created by peikua on 15/9/15.
//  Copyright (c) 2015年 peikua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)
+ (NSData *)base64DataFromString:(NSString *)string;

//北京时间转化为当地时间的方法
+(NSDate *)getLocationTimefromBeiJingTime:(NSDate*)beijingTime;

//当地时间转化为北京时间
+(NSDate *)getBeiJingTimeFromLocationTime:(NSDate*)CLocationTimsa;


//世界标准时间转换为系统时区对应时间（ps: 时间后面有＋0000 表示的是当前时间是个世界时间。）
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate;

//将本地日期字符串转为UTC日期字符串
+ (NSString *)getUTCFormateLocalDate:(NSString *)localDate;

+ (NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate;

//时间转换为指定的字符串
+(NSString *)dateChangString:(NSDate*)newTimeDate WithFormater:(NSString *)formaterStr;

//字符串转化为时间数据
+(NSDate *)StringChangDate:(NSString*)timeString WithFormater:(NSString *)formaterStr;

//转换旧的时间格式为一种新的时间格式
+ (NSDate *)switchOldDate:(NSDate *)oldDate withNewFormater:(NSString *)NewFormaterStr oldFormater:(NSString *)oldFormater;

/**
 依照某种格式比较2个时间大小
 @param NSComparisonResult
 @return   NSOrderedDescending oneDay>anotherDay \\ NSOrderedAscending oneDay<anotherDay
 */
+(NSComparisonResult)compareOneDay:(NSString *)oneDay withAnotherDay:(NSString *)anotherDay andTheFormater:(NSString *)formaterStr;

//求两个时间间隔
+(NSInteger)numberOfDaysFrom:(NSString *)currentTime  withNextTime:(NSString *)nextTime;

@end
