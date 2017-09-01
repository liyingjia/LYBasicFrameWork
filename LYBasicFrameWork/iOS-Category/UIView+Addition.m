//
//  UIView+Addition.m
//  UIViewDemo4
//
//  Created by Hailong.wang on 15/7/29.
//  Copyright (c) 2015年 Hailong.wang. All rights reserved.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)
//宽
- (CGFloat)widths {
    return self.frame.size.width;
}

//高
- (CGFloat)heights {
    return self.frame.size.height;
}

//上
- (CGFloat)tops {
    return self.frame.origin.y;
}

//下
- (CGFloat)bottoms {
    return self.frame.origin.y + self.frame.size.height;
}

//左
- (CGFloat)lefts {
    return self.frame.origin.x;
}

//右
- (CGFloat)rights {
    return self.frame.origin.x + self.frame.size.width;
}

-(CGFloat)centerX{
    return self.center.x;
}

-(CGFloat)centerY{
    return self.center.y;
}

//设置宽
- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

//设置高
- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

//设置x
- (void)setXOffset:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

//设置y
- (void)setYOffset:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

//设置Origin
- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

//设置size
- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

-(void)setCenterX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

-(void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

-(void)setViewRoundedCorners:(CGFloat)cornerRadius borderColor:(UIColor *)color borderWidth:(NSInteger)width backGoundColor:(UIColor *)backColor{
    self.backgroundColor = backColor;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

+ (CGFloat)contentHeight:(NSString *)str width:(CGFloat)width{
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    CGRect rect = [str boundingRectWithSize:CGSizeMake(width,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.height;
}

+ (CGFloat)contentWidtht:(NSString *)str height:(CGFloat)height{
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT,height) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.width;
}


//求自使用高度
+ (CGFloat)contentHeight:(NSString *)str width:(CGFloat)width font:(NSInteger)font{
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:font]};
    CGRect rect = [str boundingRectWithSize:CGSizeMake(width,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.height;
}
//求自适应宽度
+ (CGFloat)contentWidtht:(NSString *)str height:(CGFloat)height font:(NSInteger)font{
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:font]};
    CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT,height) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.width;
}

@end
