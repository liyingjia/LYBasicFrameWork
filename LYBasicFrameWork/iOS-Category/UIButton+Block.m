//
//  UIButton+Block.m
//  MRDLibrary
//
//  Created by ma ruiduan on 13-2-28.
//  Copyright (c) 2013年 ruiduan ma. All rights reserved.
//


#import "UIButton+Block.h"

@implementation UIButton(Block)

static const char *overviewKey = "buttonActionKey";

+ (UIButton *)buttonWithBackgroundColor:(UIColor *)backgroundColor
                                  title:(NSString *)title
                         titleLabelFont:(UIFont *)font
                             titleColor:(UIColor *)titleColor
                                 target:(id)target
                                 action:(SEL)action
                          clipsToBounds:(BOOL)clipsToBounds {
    
    UIButton *button = [[UIButton alloc] init];
    if (clipsToBounds) button.layer.cornerRadius = 5;
    //    button.clipsToBounds = clipsToBounds;
    button.backgroundColor = backgroundColor;
    button.titleLabel.font = font;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock)block {
    //这个方法的是意思是为UIButton这个类添加一个属性叫block,overviewKey是键值
    objc_setAssociatedObject(self, overviewKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(ActionBlock:) forControlEvents:event];
}

- (void)block:(ActionBlock)block{
    objc_setAssociatedObject(self, overviewKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(ActionBlock:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)ActionBlock:(id)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, overviewKey);
    if (block) {
        block(sender);
    }
}

-(void)setButtonRoundedCorners:(CGFloat)cornerRadius borderColor:(UIColor *)color borderWidth:(NSInteger)width backGoundColor:(UIColor *)backColor title:(NSString *)title titleColor:(UIColor *)titleColor{
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    self.backgroundColor = backColor;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    
}
-(void)setButtonRoundedCorners:(CGFloat)cornerRadius borderColor:(UIColor *)color borderWidth:(NSInteger)width backGoundColor:(UIColor *)backColor title:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font {
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    self.backgroundColor = backColor;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    self.titleLabel.font = font;
}



@end
