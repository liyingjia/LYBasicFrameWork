//
//  UIView+Addition.h
//  UIViewDemo4
//
//  Created by Hailong.wang on 15/7/29.
//  Copyright (c) 2015年 Hailong.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Addition)



//宽
- (CGFloat)widths;

//高
- (CGFloat)heights;

//上
- (CGFloat)tops;

//下
- (CGFloat)bottoms;

//左
- (CGFloat)lefts;

//右
- (CGFloat)rights;

//垂直中心
-(CGFloat)centerX;

//水平中心
-(CGFloat)centerY;

//设置宽
- (void)setWidth:(CGFloat)width;

//设置高
- (void)setHeight:(CGFloat)height;

//设置x
- (void)setXOffset:(CGFloat)x;

//设置y
- (void)setYOffset:(CGFloat)y;

//设置Origin
- (void)setOrigin:(CGPoint)origin;

//设置size
- (void)setSize:(CGSize)size;

-(void)setCenterX:(CGFloat)centerX;

-(void)setCenterY:(CGFloat)centerY;


-(void)setViewRoundedCorners:(CGFloat)cornerRadius borderColor:(UIColor *)color borderWidth:(NSInteger)width backGoundColor:(UIColor *)backColor;


//求自使用高度
+ (CGFloat)contentHeight:(NSString *)str width:(CGFloat)width;
//求自适应宽度
+ (CGFloat)contentWidtht:(NSString *)str height:(CGFloat)height;

//求自使用高度
+ (CGFloat)contentHeight:(NSString *)str width:(CGFloat)width font:(NSInteger)font;
//求自适应宽度
+ (CGFloat)contentWidtht:(NSString *)str height:(CGFloat)height font:(NSInteger)font;


@end
