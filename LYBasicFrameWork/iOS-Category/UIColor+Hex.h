//
//  UIColor+Hex.h
//  CommontCateGory
//
//  Created by liying on 17/8/11.
//  Copyright © 2017年 liying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+(UIColor *)colorFromHexString:(NSString*)colorString;

+ (UIColor *)colorWithHexString:(NSString *)color;

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

+ (UIColor *)colorWithHex:(uint) hex;
+ (UIColor *)colorWithHex:(uint) hex andAlpha:(float) alpha;

@end
