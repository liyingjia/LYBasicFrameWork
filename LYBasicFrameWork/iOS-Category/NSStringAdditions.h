//
//  NSStringAdditions.h
//  connectorTest
//
//  Created by liying on 15/12/4.
//  Copyright © 2015年 lianchuan.company. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (TKCategory)

- (NSString *)formatCurrency;
//- (NSString *)formatCurrencyStyleWithString;

- (BOOL)isAlpha;

- (BOOL)isNumber;

- (BOOL)isWhitespace;
// 验证手机号码
- (BOOL)isValidateMobileNumber;

//是否包含某个字符串
-(BOOL)isContainOfString:(NSString *)aString;
//是否为空字符串
- (BOOL)isEmptyOrWhitespace;
//是否包含表情
+ (BOOL)stringContainsEmoji:(NSString *)string;


//计算字符串长度
- (int)charNumberOfStr;

- (NSString *)stringByTrimmingWhitespaceCharacters;

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;

/**
  去掉两端空格
 */
- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters;

- (NSString*)stringByRemovingHTMLTags;

/**
 *
 *  @brief 返回隐藏后的电话号码
 *
 *  @param num 中间几位数字为 *
 *
 *  @return 返回中间四位是***隐藏后的电话号码
 */
- (NSString *)hiddenMiddleNumberOfPhoneNumbersIn:(int)num;

//去掉所有的空格和特殊字符串
+ (NSString *)stringByTrimmingWhitespace:(NSString *)string;

- (NSString *)trim;

+ (NSString *)notNull:(NSString *)str;

+ (NSString *)valueNotNull:(NSString *)str;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


///-----------------------------------
/// @name HTML Escaping and Unescaping
///-----------------------------------

/**
 Returns a new string with any HTML escaped.
 
 */
- (NSString *)escapeHTML;

/**
 Returns a new string with any HTML unescaped.
 */
- (NSString *)unescapeHTML;

@end


@interface NSString (version)

- (NSComparisonResult)versionStringCompare:(NSString *)other;

@end


@interface NSString (NSURL)

- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding;

- (NSString*)stringByAddingQuery:(NSDictionary*)query;

- (NSString*)urlEncodeValue;

- (NSString*)urlDecodeValue;

@end

@interface NSString (UUID)

+ (NSString*)stringWithNewUUID;

@end


@interface NSString (md5)

- (NSString *) md5CodeStr;

@end

@interface NSString (data)

//精确度为6位
- (double)numberWithDrecision;

@end

//正则比较
@interface NSString (WHLCanonical)

- (BOOL)isChinese;

//有字母,数字下滑线组成
- (BOOL)isValidateUserName;

//有中英文,数字下滑线组成
- (BOOL)isValidateName;

//有中英文,数字组成
- (BOOL)isValidateSecretNum;

//纯数字
-(BOOL)isNum;

/**
 *  正则验证身份证号
 *
 *  @param identityCard 传入的身份证号
 *
 *  @return YES则是身份证号
 */
- (BOOL)isIdCard: (NSString *)identityCard;

- (BOOL)simpleVerifyIdentityCardNum;

/**
 *  精确的身份证号码有效性检测
 *
 *  @param value 身份证号
 */
+ (BOOL)accurateVerifyIDCardNumber:(NSString *)value;

@end
