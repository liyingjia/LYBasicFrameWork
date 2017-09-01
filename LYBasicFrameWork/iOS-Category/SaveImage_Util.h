//
//  SaveImage_Util.h
//  FoodYou
//
//  Created by liying on 17/7/27.
//  Copyright © 2017年 AZLP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SaveImage_Util : NSObject

#pragma mark  保存图片到document
+ (BOOL)saveImage:(UIImage *)saveImage ImageName:(NSString *)imageName back:(void(^)(NSString *imagePath))back;

@end
