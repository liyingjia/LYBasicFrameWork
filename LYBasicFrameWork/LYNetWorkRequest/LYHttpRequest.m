//
//  LYHttpRequest.m
//  CommontCateGory
//
//  Created by liying on 17/8/18.
//  Copyright © 2017年 liying. All rights reserved.
//

#import "LYHttpRequest.h"
#import "LYNetRequestManager.h"

@implementation LYHttpRequest

//调用接口方式 参数转为json放入info
+ (void)postRequestHeadDict:(NSDictionary * )head postUrl:(NSString *)postUrl parameter:(NSDictionary *) paraDict successBlock:(LYRequestSuccess)succeeBlock fail:(LYRequestFail)fail{
    NSString* requestURL =
    [NSString stringWithFormat:@"%@%@", @"baseUrl", postUrl];
    [LYNetRequestManager configRequestType:LYRequestTypePlainText
                            responseType:LYResponseTypeJSON
                     shouldAutoEncodeUrl:NO
                 callbackOnCancelRequest:YES];
    NSMutableDictionary *param = [NSMutableDictionary new];
    //转json
//    param[@"info"] = [paraDict mj_JSONString];
    [LYNetRequestManager postWithUrl:requestURL
                          headDict:head
                      refreshCache:NO
                            params:param
                           success:^(id respond) {
                               succeeBlock(respond);
                           }
                              fail:^(NSError* error) {
                                  fail(error.description);
                              }];
    
}

//上传数据接口方式  参数为数组
+ (void)postValueHeadDict:(NSDictionary * )head postUrl:(NSString *)postUrl parameter:(NSMutableArray *) paraDict successBlock:(LYRequestSuccess)succeeBlock fail:(LYRequestFail)fail{
    NSString* requestURL =
    [NSString stringWithFormat:@"%@%@", postUrl, postUrl];
    [LYNetRequestManager configRequestType:LYRequestTypePlainText
                            responseType:LYResponseTypeJSON
                     shouldAutoEncodeUrl:NO
                 callbackOnCancelRequest:YES];
    NSMutableDictionary *param = [NSMutableDictionary new];
//    param[@"info"] = [paraDict mj_JSONString];
    [LYNetRequestManager postWithUrl:requestURL
                          headDict:head
                      refreshCache:NO
                            params:param
                           success:^(id respond) {
                               succeeBlock(respond);
                           }
                              fail:^(NSError* error) {
                                  fail(error.description);
                              }];
    
}

//上传图片
+(void)postImageWithImage:(UIImage * )image fileName:(NSString *)fileName name:(NSString *)name postUrl:(NSString *)postUrl parameter:(NSDictionary *) paraDict successBlock:(LYRequestSuccess)succeeBlock fail:(LYRequestFail)fail{
    NSString* requestURL = [NSString stringWithFormat:@"%@%@", postUrl, postUrl];
    [LYNetRequestManager configRequestType:LYRequestTypePlainText
                            responseType:LYResponseTypeJSON
                     shouldAutoEncodeUrl:NO
                 callbackOnCancelRequest:YES];
    NSMutableDictionary *param = [NSMutableDictionary new];
//    param[@"info"] = [paraDict mj_JSONString];
    [LYNetRequestManager uploadWithImage:image url:requestURL fileName:fileName name:name mimeTpe:@"" parameters:param success:^(id respond) {
        succeeBlock(respond);
    } fail:^(NSError *error) {
        fail(error.description);
    }];
}


//上传多张图片方法
+(void)postImageWithImageArr:(NSArray * )images fileName:(NSString *)fileName name:(NSString *)name postUrl:(NSString *)postUrl parameter:(NSDictionary *) paraDict successBlock:(LYRequestSuccess)succeeBlock fail:(LYRequestFail)fail{
    NSString* requestURL = [NSString stringWithFormat:@"%@%@", postUrl, postUrl];
    [LYNetRequestManager configRequestType:LYRequestTypePlainText
                            responseType:LYResponseTypeJSON
                     shouldAutoEncodeUrl:NO
                 callbackOnCancelRequest:YES];
    NSMutableDictionary *param = [NSMutableDictionary new];
//    param[@"info"] = [paraDict mj_JSONString];
    [LYNetRequestManager uploadWithImageArr:images url:requestURL fileName:fileName name:name mimeTpe:@"" parameters:param success:^(id respond) {
        succeeBlock(respond);
    } fail:^(NSError *error) {
        fail(error.description);
    }];
}

//下载文件
+(void)downloadWithUrl:(NSString*)url saveToPath:(NSString*)saveToPath success:(LYRequestSuccess)success failure:(LYRequestFail)failure{
    [LYNetRequestManager configRequestType:LYRequestTypePlainText
                            responseType:LYResponseTypeJSON
                     shouldAutoEncodeUrl:NO
                 callbackOnCancelRequest:YES];
    [LYNetRequestManager downloadWithUrl:url saveToPath:saveToPath progress:^(ino64_t bytesRead, int64_t totalBytesdRead) {
       
    } success:^(id respond) {
        success(respond);
    } failure:^(NSError *error) {
        failure(error.description);
    }];
}

+ (void)getRequestHeadDict:(NSDictionary * )head getUrl:(NSString *)getUrl parameter:(NSDictionary *) paraDict successBlock:(LYRequestSuccess)succeeBlock fail:(LYRequestFail)fail{
    [LYNetRequestManager configRequestType:LYRequestTypePlainText
                            responseType:LYResponseTypeJSON
                     shouldAutoEncodeUrl:NO
                 callbackOnCancelRequest:YES];
    [LYNetRequestManager getWithUrl:getUrl headDict:head refreshCache:NO params:paraDict success:^(id respond) {
        succeeBlock(respond);
    } fail:^(NSError *error) {
        fail(error.description);
    }];
}


@end
