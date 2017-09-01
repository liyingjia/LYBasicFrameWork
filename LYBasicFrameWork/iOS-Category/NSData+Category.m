//
//  PK-ios
//
//  Created by peikua on 15/9/15.
//  Copyright (c) 2015年 peikua. All rights reserved.
//

#import "NSData+Category.h"


@implementation NSData (Base64)

+ (NSData*) base64DataFromString:(NSString *)string {
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    if (string == nil) {
        return [NSData data];
    }
    
    ixtext = 0;
    
    tempcstring = (const unsigned char *)[string UTF8String];
    
    lentext = [string length];
    
    theData = [NSMutableData dataWithCapacity: lentext];
    
    ixinbuf = 0;
    
    while (true) {
        if (ixtext >= lentext) {
            break;
        }
        
        ch = tempcstring [ixtext++];
        
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z')) {
            ch = ch - 'A';
        }
        else if ((ch >= 'a') && (ch <= 'z')) {
            ch = ch - 'a' + 26;
        }
        else if ((ch >= '0') && (ch <= '9')) {
            ch = ch - '0' + 52;
        }
        else if (ch == '+') {
            ch = 62;
        }
        else if (ch == '=') {
            flendtext = true;
        }
        else if (ch == '/') {
            ch = 63;
        }
        else {
            flignore = true;
        }
        
        if (!flignore) {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext) {
                if (ixinbuf == 0) {
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2)) {
                    ctcharsinbuf = 1;
                }
                else {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                
                flbreak = true;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if (ixinbuf == 4) {
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++) {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak) {
                break;
            }
        }
    }
    
    return theData;
}


+(NSDate*)getLocationTimefromBeiJingTime:(NSDate*)beijingTime
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:beijingTime];
    //源日期与目标时区的时间的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:beijingTime];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:beijingTime] ;
    return destinationDateNow;
    
}
//当地时间转化为北京时间
+(NSDate*)getBeiJingTimeFromLocationTime:(NSDate*)CLocationTimsa
{
    //    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    NSTimeZone* destinationTimeZone=[NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSInteger bjInterval = [destinationTimeZone secondsFromGMTForDate:CLocationTimsa];
    NSDate *bjDate = [CLocationTimsa  dateByAddingTimeInterval:bjInterval]; //直接转为北京时间
    return bjDate;
    
}


+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

//将本地日期字符串转为UTC日期字符串
//本地日期格式:2013-08-03 12:53:51
//可自行指定输入输出格式

+ (NSString *)getUTCFormateLocalDate:(NSString *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:localDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

//将UTC日期字符串转为本地时间字符串
//输入的UTC日期格式2013-08-03T04:53:51+0000
+ (NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}



//时间转换为字符串
+(NSString*)dateChangString:(NSDate*)newTimeDate WithFormater:(NSString *)formaterStr
{
    NSDateFormatter*formatter=[[NSDateFormatter alloc]init];
    //    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];//不自动+8小时
    [formatter setDateFormat:formaterStr];
    NSString*nowDateString=[formatter stringFromDate:newTimeDate];
    return nowDateString;
}

//字符串转化为时间数据
+(NSDate*)StringChangDate:(NSString*)timeString WithFormater:(NSString *)formaterStr
{
    NSDateFormatter*formatter=[[NSDateFormatter alloc]init];
    //    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];//世界时间样式（不会根据系统时间自动对数据进行时区自动增加时区差值。）
    [formatter setDateFormat:formaterStr];
    NSDate*nowDate=[formatter dateFromString:timeString];
    return nowDate;
}


+ (NSDate *)switchOldDate:(NSDate *)oldDate withNewFormater:(NSString *)NewFormaterStr oldFormater:(NSString *)oldFormater{
    NSDateFormatter * dateFormater = [[NSDateFormatter alloc]init];
    [dateFormater setDateFormat:oldFormater];
    NSString * oldDateStr = [dateFormater stringFromDate:oldDate];
    [dateFormater setDateFormat:NewFormaterStr];
    return [dateFormater dateFromString:oldDateStr];
    
}

//比较两个时间的大小
+(NSComparisonResult)compareOneDay:(NSString *)oneDay withAnotherDay:(NSString *)anotherDay andTheFormater:(NSString *)formaterStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formaterStr];
    NSDate *dateA = [dateFormatter dateFromString:oneDay];
    NSDate *dateB = [dateFormatter dateFromString:anotherDay];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
    
    //    if (result == NSOrderedDescending) {//dateA比dateB大
    //        //NSLog(@"Date1  is in the future");
    //        return 1;
    //    }
    //    else if (result == NSOrderedAscending){//dateA比dateB小
    //
    //        //NSLog(@"Date1 is in the past");
    //        return -1;
    //    }
    //    //NSLog(@"Both dates are the same");
    //    return 0;
    return result;
}


//根据两个时间求时间间隔
+(NSInteger)numberOfDaysFrom:(NSString *)currentTime  withNextTime:(NSString *)nextTime{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //    [gregorian setFirstWeekday:2];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *fromDate = [dateFormatter dateFromString:currentTime];
    NSString *subMonthStr = [nextTime substringToIndex:10];
    NSDate *toDate = [dateFormatter dateFromString:subMonthStr];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    //    NSRange range= {11,2};
    //    NSInteger inter = [[nextTime substringWithRange:range]integerValue];
    return dayComponents.day;
}


@end

