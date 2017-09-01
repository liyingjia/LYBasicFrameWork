//
//  NSStringAdditions.m
//  connectorTest
//
//  Created by 王浩霖 on 15/12/4.
//  Copyright © 2015年 lianchuan.company. All rights reserved.
//

#import "NSStringAdditions.h"
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
//////////////////////////////////////////////////////////////////////////////////////////////////

@interface TKMarkupStripper : NSObject<NSXMLParserDelegate> {
    NSMutableArray* _strings;
}

- (NSString*)parse:(NSString*)string;

@end

@implementation TKMarkupStripper

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
    self = [super init];
    if (self) {
        _strings = nil;
    }
    return self;
}

- (void)dealloc {
    _strings = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_strings addObject:string];
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID {
    static NSDictionary* entityTable = nil;
    if (!entityTable) {
        // XXXjoe Gotta get a more complete set of entities
        entityTable = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [NSData dataWithBytes:" " length:1], @"nbsp",
                       [NSData dataWithBytes:"&" length:1], @"amp",
                       [NSData dataWithBytes:"\"" length:1], @"quot",
                       [NSData dataWithBytes:"<" length:1], @"lt",
                       [NSData dataWithBytes:">" length:1], @"gt",
                       nil];
    }
    return [entityTable objectForKey:entityName];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSString*)parse:(NSString*)text {
    _strings = [[NSMutableArray alloc] init];
    
    NSString* document = [NSString stringWithFormat:@"<x>%@</x>", text];
    NSData* data = [document dataUsingEncoding:text.fastestEncoding];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data] ;
    parser.delegate = self;
    [parser parse];
    
    return [_strings componentsJoinedByString:@""];
}

@end

//TK_FIX_CATEGORY_BUG(NSStringAdditions)

@implementation NSString (TKCategory)

- (NSString *)formatCurrency {
    NSString *nstr = [NSString stringWithFormat:@"%.2f",[self doubleValue]];
    nstr = [nstr stringByReplacingOccurrencesOfString:@".00" withString:@""];
    return nstr;
    //    NSRange range = [nstr rangeOfString:@"."];
    //    if (range.location!= NSNotFound && range.length>0) {
    
    //        return [self formatCurrencyStyleWithString];
    //    }
    //    return [self formatJpAmountString];
}



- (NSString *)formatCurrencyStyleWithString
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    NSString *formattedNumberString;
    if ([self hasPrefix:@"+"]||[self hasPrefix:@"-"]) {
        [numberFormatter setPositivePrefix:@"+"];
        [numberFormatter setPositiveSuffix:@""];
        [numberFormatter setNegativePrefix:@"-"];
        [numberFormatter setNegativeSuffix:@""];
    }else{
        [numberFormatter setPositivePrefix:@""];
    }
    formattedNumberString = [numberFormatter stringFromNumber:[[NSDecimalNumber alloc] initWithString:self]];
    return formattedNumberString;
}

- (NSString *)formatJpAmountString
{
    NSDecimalNumber *multiplierNumber = [NSDecimalNumber decimalNumberWithString:self];
    CFLocaleRef currentLocale = CFLocaleCopyCurrent();
    CFNumberFormatterRef numberFormatter = CFNumberFormatterCreate(NULL, currentLocale, kCFNumberFormatterCurrencyStyle);
    CFNumberFormatterSetFormat(numberFormatter, CFSTR("####"));
    NSString *formattedNumberString = (__bridge NSString *)(CFNumberFormatterCreateStringWithNumber(NULL, numberFormatter, (__bridge  CFNumberRef)(multiplierNumber)));
    return formattedNumberString;
}

- (BOOL)isAlpha
{
    for (int i = 0; i < [self length]; i++) {
        char c = [self characterAtIndex:i];
        if (!isalpha(c)) {
            return NO;
        }
    }
    return [self length] != 0;
}

- (BOOL)isNumber
{
    for (int i = 0; i < [self length]; i++) {
        char c = [self characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return [self length] != 0;
}

//是否包含表情
+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

// 验证手机号码
- (BOOL)isValidateMobileNumber
{
    //手机号以13， 15，18开头，八个 \d 数字字符 （新增14、17号段）
    NSString *phoneRegex = @"^((13[0-9])|(14[5,7])|(15[^4,\\D])|(17[0,6-8])|(18[0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:self];
}

- (BOOL)isWhitespace {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![whitespace characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}

-(BOOL)isContainOfString:(NSString *)aString
{
    NSRange  range = [self rangeOfString:aString];
    if (range.length > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isEmptyOrWhitespace {
    return !self.length ||
    ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}



#pragma mark -
#pragma mark 字符串处理

//计算NSString中英文字符串的字符长度。ios 中一个汉字算2字符数
- (int)charNumberOfStr
{
    int strlength = 0;
    char* p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        } else {
            p++;
        }
    }
    return strlength;
}

/**
 *
 *  @brief 返回隐藏后的电话号码
 *
 *  @param num 中间几位数字为 *
 *
 *  @return 返回中间四位是***隐藏后的电话号码
 */
- (NSString *)hiddenMiddleNumberOfPhoneNumbersIn:(int)num{
    
    NSInteger count = [self length];
    
    NSString * str1 = [self substringToIndex: num - 1];//到第几个
    NSString * str2 = [self substringFromIndex: count - num];
    
    return  [NSString stringWithFormat:@"%@****%@",str1,str2];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
                                                               options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringToIndex:rangeOfLastWantedCharacter.location+1]; // non-inclusive
}

- (NSString *)stringByTrimmingWhitespaceCharacters
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingTrailingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString*)stringByRemovingHTMLTags {
    TKMarkupStripper* stripper = [[TKMarkupStripper alloc] init] ;
    return [stripper parse:self];
}

+ (NSString *)stringByTrimmingWhitespace:(NSString *)string
{
    NSString* returnStr = string;
    returnStr = [returnStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    returnStr = [returnStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    return returnStr;
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)notNull:(NSString *)str
{
    if (str==nil) {
        return @"";
    }
    if (!str || [str isKindOfClass:[NSNull class]] || [str isEqualToString:@"(null)"]) {
        return @"";
    }
    return str;
}

+ (NSString *)valueNotNull:(NSString *)str{
    if ([str isKindOfClass:[NSString class]]) {
        return [self notNull:str];
    }
    if ([str isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)str;
        return [number stringValue];
    }
    return @"";
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - HTML Methods

- (NSString *)escapeHTML {
    NSMutableString *s = [NSMutableString string];
    
    NSUInteger start = 0;
    NSUInteger len = [self length];
    NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"<>&\""];
    
    while (start < len) {
        NSRange r = [self rangeOfCharacterFromSet:chs options:0 range:NSMakeRange(start, len-start)];
        if (r.location == NSNotFound) {
            [s appendString:[self substringFromIndex:start]];
            break;
        }
        
        if (start < r.location) {
            [s appendString:[self substringWithRange:NSMakeRange(start, r.location-start)]];
        }
        
        switch ([self characterAtIndex:r.location]) {
            case '<':
                [s appendString:@"&lt;"];
                break;
            case '>':
                [s appendString:@"&gt;"];
                break;
            case '"':
                [s appendString:@"&quot;"];
                break;
                //			case '…':
                //				[s appendString:@"&hellip;"];
                //				break;
            case '&':
                [s appendString:@"&amp;"];
                break;
        }
        
        start = r.location + 1;
    }
    
    return s;
}

- (NSString *)unescapeHTML {
    NSMutableString *s = [NSMutableString string];
    NSMutableString *target = [self mutableCopy];
    NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    
    while ([target length] > 0) {
        NSRange r = [target rangeOfCharacterFromSet:chs];
        if (r.location == NSNotFound) {
            [s appendString:target];
            break;
        }
        
        if (r.location > 0) {
            [s appendString:[target substringToIndex:r.location]];
            [target deleteCharactersInRange:NSMakeRange(0, r.location)];
        }
        
        if ([target hasPrefix:@"&lt;"]) {
            [s appendString:@"<"];
            [target deleteCharactersInRange:NSMakeRange(0, 4)];
        } else if ([target hasPrefix:@"&gt;"]) {
            [s appendString:@">"];
            [target deleteCharactersInRange:NSMakeRange(0, 4)];
        } else if ([target hasPrefix:@"&quot;"]) {
            [s appendString:@"\""];
            [target deleteCharactersInRange:NSMakeRange(0, 6)];
        } else if ([target hasPrefix:@"&#39;"]) {
            [s appendString:@"'"];
            [target deleteCharactersInRange:NSMakeRange(0, 5)];
        } else if ([target hasPrefix:@"&amp;"]) {
            [s appendString:@"&"];
            [target deleteCharactersInRange:NSMakeRange(0, 5)];
        } else if ([target hasPrefix:@"&hellip;"]) {
            [s appendString:@"…"];
            [target deleteCharactersInRange:NSMakeRange(0, 8)];
        } else {
            [s appendString:@"&"];
            [target deleteCharactersInRange:NSMakeRange(0, 1)];
        }
    }
    
    return s;
}

@end

@implementation NSString (version)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSComparisonResult)versionStringCompare:(NSString *)other {
    NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
    NSArray *twoComponents = [other componentsSeparatedByString:@"a"];
    
    // The parts before the "a"
    NSString *oneMain = [oneComponents objectAtIndex:0];
    NSString *twoMain = [twoComponents objectAtIndex:0];
    
    // If main parts are different, return that result, regardless of alpha part
    NSComparisonResult mainDiff;
    if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
        return mainDiff;
    }
    
    // At this point the main parts are the same; just deal with alpha stuff
    // If one has an alpha part and the other doesn't, the one without is newer
    if ([oneComponents count] < [twoComponents count]) {
        return NSOrderedDescending;
        
    } else if ([oneComponents count] > [twoComponents count]) {
        return NSOrderedAscending;
        
    } else if ([oneComponents count] == 1) {
        // Neither has an alpha part, and we know the main parts are the same
        return NSOrderedSame;
    }
    
    // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
    // numerically. If it's not a valid number (including empty string) it's treated as zero.
    NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
    NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
    return [oneAlpha compare:twoAlpha];
}

@end

@implementation NSString (NSURL)


- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding {
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
    while (![scanner isAtEnd]) {
        NSString* pairString;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0]
                             stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString* value = [[kvPair objectAtIndex:1]
                               stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:pairs];
}


- (NSString*)stringByAddingQuery:(NSDictionary*)query {
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [query keyEnumerator]) {
        id aValue = [query objectForKey:key];
        NSString *value = nil;
        if (![aValue isKindOfClass:[NSString class]]) {
            
            value = [aValue description];
        } else {
            value = aValue;
        }
        value = [value stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
        value = [value stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
        NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
        [pairs addObject:pair];
    }
    
    NSString* params = [pairs componentsJoinedByString:@"&"];
    if ([self rangeOfString:@"?"].location == NSNotFound) {
        return [self stringByAppendingFormat:@"?%@", params];
    } else {
        return [self stringByAppendingFormat:@"&%@", params];
    }
}


- (NSString*)urlEncodeValue {
  NSString* encodedString =
      (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
          kCFAllocatorDefault, (CFStringRef)self, NULL,
          (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));

  return encodedString;
}


- (NSString*)urlDecodeValue {
  NSString* decodedString = (__bridge_transfer NSString*)
      CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
          NULL, (__bridge CFStringRef)self, CFSTR(""),
          CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
  return decodedString;
}

@end;

@implementation NSString (UUID)


+ (NSString*)stringWithNewUUID
{
    // Create a new UUID
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    
    // Get the string representation of the UUID
    NSString *newUUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return newUUID ;
}


@end

@implementation NSString (md5)

- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    
    CC_MD5( cStr, strlen(cStr), result ); 
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

- (NSString *) md5CodeStr{
    
    if (self == nil || [self length] == 0) {
        return nil;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([self UTF8String], (int)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", (int)(digest[i])];
    }
    return [ms copy];
}


@end

@implementation NSString (data)
/**
  精确到小数点后6位
 */
- (double)numberWithDrecision
{
    double oldDoudle = [self doubleValue];
    NSNumberFormatter * nf = [[NSNumberFormatter alloc]init];
    [nf setMaximumFractionDigits:6];
    NSNumber * newNumber = [nf numberFromString:[NSString stringWithFormat:@"%.6lf",oldDoudle]];
    return [newNumber doubleValue];
}

@end

@implementation NSString (WHLCanonical)

- (BOOL)isChinese{
    NSString *match=@"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}
//有中英文,数字或下滑线组成
- (BOOL)isValidateName{
    NSString *match = @"^[a-zA-Z0-9_\u4e00-\u9fa5]{4,20}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

//有英文,数字或下滑线组成
- (BOOL)isValidateUserName{
    NSString *match = @"^[a-zA-Z0-9_]{4,20}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

//有英文,数字组成
- (BOOL)isValidateSecretNum{
    NSString *match = @"^[a-zA-Z0-9]{6,16}+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

//纯数字
-(BOOL)isNum{
    NSString *match = @"^[0-9]{6}+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

//正则监测身份证号
- (BOOL)isIdCard: (NSString *)identityCard{
//    BOOL flag;
//    if (identityCard.length <= 0) {
//        flag = NO;
//        return flag;
//    }
//    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
//    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
//    return [identityCardPredicate evaluateWithObject:identityCard];
    NSString *pattern = @"^[0-9]{15}$)|([0-9]{17}([0-9]|X)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:identityCard];
    return isMatch;
}


#pragma mark - 算法相关
//精确的身份证号码有效性检测
+ (BOOL)accurateVerifyIDCardNumber:(NSString *)value {
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    int length =0;
    if (!value) {
        return NO;
    }else {
        length = (int)value.length;
        
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag =NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return false;
    }
    
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    switch (length) {
        case 15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                int Y = S %11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                    return YES;// 检测ID的校验位
                }else {
                    return NO;
                }
                
            }else {
                return NO;
            }
        default:
            return NO;
    }
}


@end



