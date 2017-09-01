//
//  LYHttpRequest.h
//  CommontCateGory
//
//  Created by liying on 17/8/18.
//  Copyright © 2017年 liying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^LYRequestSuccess)(id response);
typedef void(^LYRequestFail)(id error);

@interface LYHttpRequest : NSObject

/**
 通用POST接口
 @param head	请求头没有就传为空
 @param postUrl 此处为拼接的地址
 @param paraDict	请求参数
 @param succeeBlock  成功回调
 @param fail  失败回调
 */

+ (void)postRequestHeadDict:(NSDictionary * )head postUrl:(NSString *)postUrl parameter:(NSDictionary *) paraDict successBlock:(LYRequestSuccess)succeeBlock fail:(LYRequestFail)fail;


//上传图片方法
+(void)postImageWithImage:(UIImage * )image fileName:(NSString *)fileName name:(NSString *)name postUrl:(NSString *)postUrl parameter:(NSDictionary *) paraDict successBlock:(LYRequestSuccess)succeeBlock fail:(LYRequestFail)fail;

//上传多张图片方法
+(void)postImageWithImageArr:(NSArray * )images fileName:(NSString *)fileName name:(NSString *)name postUrl:(NSString *)postUrl parameter:(NSDictionary *) paraDict successBlock:(LYRequestSuccess)succeeBlock fail:(LYRequestFail)fail;

//下载文件方法
+(void)downloadWithUrl:(NSString*)url
            saveToPath:(NSString*)saveToPath
               success:(LYRequestSuccess)success
               failure:(LYRequestFail)failure;

//get请求方法
+ (void)getRequestHeadDict:(NSDictionary * )head getUrl:(NSString *)getUrl parameter:(NSDictionary *) paraDict successBlock:(LYRequestSuccess)succeeBlock fail:(LYRequestFail)fail;

@end
