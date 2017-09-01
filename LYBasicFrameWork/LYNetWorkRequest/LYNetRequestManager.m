//
//  LYNetRequestManager.m
//  CommontCateGory
//
//  Created by liying on 17/8/18.
//  Copyright © 2017年 liying. All rights reserved.
//

#import "LYNetRequestManager.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworking.h"
#import "NSStringAdditions.h"

#ifdef DEBUG

#define debug_NOFileLog(format, ...)                \
do {                                              \
NSLog(@"❤️❤️❤️❤️❤️❤️"); \
NSLog(format, ##__VA_ARGS__);                   \
NSLog(@"\n😄😄😄😄😄😄😄\n");                          \
} while (0)

#endif

static NSString* ly_NetworkBaseUrl = nil;
static LYResponseType ly_ResponseType = LYResponseTypeJSON;
static LYRequestType ly_RequesetType = LYRequestTypeJSON;
static NSMutableArray* ly_requestTasks;  //存放所有存在的请求对象
static NSTimeInterval ly_timeOut = 15.0f;

//*************
static BOOL ly_EnableInterfaceDebug = YES;
static BOOL ly_cacheGet = NO;
static BOOL ly_cachePost = NO;
static BOOL ly_gainCache = NO;
static BOOL ly_cancelCallBlack = YES;
static BOOL ly_autoEncode = NO;
static BOOL ly_encodeUTF8 = YES;

@implementation LYNetRequestManager

#pragma mark -
#pragma mark 初始化

+ (void)networkBaseUrl:(NSString*)baseUrl {
    ly_NetworkBaseUrl = baseUrl;
}

+ (void)setRequestTimeOut:(NSTimeInterval)timeout {
    ly_timeOut = timeout;
}

+ (void)openDebugModel:(BOOL)openDebug {
    ly_EnableInterfaceDebug = openDebug;
}

+ (void)configRequestType:(LYRequestType)requestType
             responseType:(LYResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
  callbackOnCancelRequest:(BOOL)shouldCallbackOnCancelRequest {
    ly_RequesetType = requestType;
    ly_ResponseType = responseType;
    ly_autoEncode = shouldAutoEncode;
    ly_cancelCallBlack = shouldCallbackOnCancelRequest;
}

+ (void)encodeUrlToUTF8:(BOOL)encode{
    ly_encodeUTF8 = encode;
}

+ (void)gainDataFromLocalWhenNetworkUnconnected:(BOOL)shouldGain {
    ly_gainCache = shouldGain;
}

+ (void)cacheGetRequest:(BOOL)isCacheGet CachePost:(BOOL)cachePost {
    ly_cacheGet = isCacheGet;
    ly_cachePost = cachePost;
}

#pragma mark -
#pragma mark 缓存清理

static inline NSString* cacheNetworkPath() {
    return [NSHomeDirectory()
            stringByAppendingPathComponent:@"Documents/NetRequestCaches"];
}

+ (unsigned long long)totalCacheSize {
    NSString* directoryPath = cacheNetworkPath();
    BOOL isDir = NO;
    unsigned long long total = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath
                                             isDirectory:&isDir]) {
        if (isDir) {
            NSError* error = nil;
            NSArray* array = [[NSFileManager defaultManager]
                              contentsOfDirectoryAtPath:directoryPath
                              error:&error];
            
            if (error == nil) {
                for (NSString* subpath in array) {
                    NSString* path =
                    [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary* dict =
                    [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                     error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    return total;
}

+ (void)clearCache {
    NSString* directoryPath = cacheNetworkPath();
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath
                                             isDirectory:nil]) {
        NSError* error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath
                                                   error:&error];
        if (error) {
            debug_NOFileLog(@" clear caches error: %@", error);
        } else {
            debug_NOFileLog(@" clear caches ok");
        }
    }
}

#pragma mark -
#pragma mark 关闭请求

+ (NSMutableArray*)allRequestTaks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ly_requestTasks == nil) {
            ly_requestTasks = [[NSMutableArray alloc] init];
        }
    });
    return ly_requestTasks;
}

+ (void)cancelAllRequest {
    @synchronized(self) {
        [[self allRequestTaks]
         enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx,
                                      BOOL* _Nonnull stop) {
             if ([obj isKindOfClass:[LYURLSessionTask class]]) {
                 LYURLSessionTask* request = obj;
                 [request cancel];
             }
         }];
        [[self allRequestTaks] removeAllObjects];
    };
}

+ (void)cancelRequestWithURL:(NSString*)url {
    if (url == nil) {
        return;
    }
    @synchronized(self) {
        [[self allRequestTaks]
         enumerateObjectsUsingBlock:^(LYURLSessionTask* _Nonnull task,
                                      NSUInteger idx, BOOL* _Nonnull stop) {
             if ([task isKindOfClass:[LYURLSessionTask class]] &&
                 [task.currentRequest.URL.absoluteString hasSuffix:url]) {
                 [task cancel];
                 [[self allRequestTaks] removeObject:task];
                 return;
             }
         }];
    };
}

#pragma mark -
#pragma mark 各种请求

+ (LYURLSessionTask*)getWithUrl:(NSString*)url
                        headDict:(NSDictionary*)header
                    refreshCache:(BOOL)refreshCache
                         success:(LYRespondSuccess)success
                            fail:(LYRespondFail)fail {
    return [self getWithUrl:url
                   headDict:header
               refreshCache:refreshCache
                     params:nil
                    success:success
                       fail:fail];
}

+ (LYURLSessionTask*)getWithUrl:(NSString*)url
                        headDict:(NSDictionary*)header
                    refreshCache:(BOOL)refreshCache
                          params:(NSDictionary*)params
                         success:(LYRespondSuccess)success
                            fail:(LYRespondFail)fail {
    return [self getWithUrl:url
                   headDict:header
               refreshCache:refreshCache
                     params:params
                   progress:nil
                    success:success
                       fail:fail];
}

+ (LYURLSessionTask*)getWithUrl:(NSString*)url
                        headDict:(NSDictionary*)header
                    refreshCache:(BOOL)refreshCache
                          params:(NSDictionary*)params
                        progress:(LYGetProgress)progress
                         success:(LYRespondSuccess)success
                            fail:(LYRespondFail)fail {
    return [self _requestWithUrl:url
                        headDict:header
                    refreshCache:refreshCache
                       httpMedth:1
                          params:params
                        progress:progress
                         success:success
                            fail:fail];
}

+ (LYURLSessionTask*)postWithUrl:(NSString*)url
                         headDict:(NSDictionary*)header
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary*)params
                          success:(LYRespondSuccess)success
                             fail:(LYRespondFail)fail {
    return [self postWithUrl:url
                    headDict:header
                refreshCache:refreshCache
                      params:params
                    progress:nil
                     success:success
                        fail:fail];
}

+ (LYURLSessionTask*)postWithUrl:(NSString*)url
                         headDict:(NSDictionary*)header
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary*)params
                         progress:(LYPostProgress)progress
                          success:(LYRespondSuccess)success
                             fail:(LYRespondFail)fail {
    return [self _requestWithUrl:url
                        headDict:header
                    refreshCache:refreshCache
                       httpMedth:2
                          params:params
                        progress:progress
                         success:success
                            fail:fail];
}

+ (LYURLSessionTask*)uploadWithImage:(UIImage*)image
                                  url:(NSString*)url
                             fileName:(NSString*)filename
                                 name:(NSString*)name
                              mimeTpe:(NSString*)mineType
                           parameters:(NSDictionary*)parameters
                              success:(LYRespondSuccess)success
                                 fail:(LYRespondFail)fail {
    if (ly_NetworkBaseUrl == nil) {
        if ([NSURL URLWithString:url] == nil) {
            debug_NOFileLog(
                            @"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                  ly_NetworkBaseUrl,
                                  url]] == nil) {
            debug_NOFileLog(
                            @"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    if (ly_autoEncode) {
        url = [self encodeUrl:url];
    }
    
    NSString* absolute = [self absoluteUrlWithPath:url];
    AFHTTPSessionManager* manager = [self LYManagerWithHead:nil];
    LYURLSessionTask* session = [manager POST:url
                                    parameters:parameters
                     constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
                         CGFloat compression = 0.9f;
                         CGFloat maxCompression = 0.1f;
                         NSData* imageData = UIImageJPEGRepresentation(image, compression);
                         while ([imageData length] > 1.0 * 1024 * 1024 &&
                                compression > maxCompression) {
                             compression -= 0.1;
                             imageData = UIImageJPEGRepresentation(image, compression);
                         }
                         debug_NOFileLog(@"❤️❤️❤️的上传图片的尺寸大小%"
                                         @"zd❤️❤️❤️",
                                         [imageData length]);
                         NSString* imageFileName = filename;
                         if (!filename) {
                             NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                             formatter.dateFormat = @"yyyyMMddHHmmss";
                             NSString* str = [formatter stringFromDate:[NSDate date]];
                             imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
                         }
                         NSLog(@"fileName:%@ file:%@",imageFileName,name);
                         [formData appendPartWithFileData:imageData
                                                     name:name ?: @"file"
                                                 fileName:imageFileName
                                                 mimeType:mineType ?: @"Multipart-form-data"];
                     }
                                      progress:^(NSProgress* _Nonnull uploadProgress) {
                                          // TODO: 这里显示进度
                                      }
                                       success:^(NSURLSessionDataTask* _Nonnull task,
                                                 id _Nullable responseObject) {
                                           [[self allRequestTaks] removeObject:task];
                                           [self successResponse:responseObject callback:success];
                                           if (ly_EnableInterfaceDebug) {
                                               [self logWithSuccessrequestHead:nil Response:responseObject url:absolute params:parameters];
                                           }
                                       }
                                       failure:^(NSURLSessionDataTask* _Nullable task, NSError* _Nonnull error) {
                                           [[self allRequestTaks] removeObject:task];
                                           [self handleCallbackWithError:error fail:fail url:url];
                                           if (ly_EnableInterfaceDebug) {
                                               [self logWithFailError:error url:absolute params:parameters];
                                           }
                                       }];
    
    //存到请求数组中
    [session resume];
    if (session) {
        [[self allRequestTaks] addObject:session];
    }
    return session;
}
//上传多张图片
+ (LYURLSessionTask*)uploadWithImageArr:(NSArray*)images
                                     url:(NSString*)url
                                fileName:(NSString*)filename
                                    name:(NSString*)name
                                 mimeTpe:(NSString*)mineType
                              parameters:(NSDictionary*)parameters
                                 success:(LYRespondSuccess)success
                                    fail:(LYRespondFail)fail {
    if (ly_NetworkBaseUrl == nil) {
        if ([NSURL URLWithString:url] == nil) {
            debug_NOFileLog(
                            @"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                  ly_NetworkBaseUrl,
                                  url]] == nil) {
            debug_NOFileLog(
                            @"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    if (ly_autoEncode) {
        url = [self encodeUrl:url];
    }
    
    NSString* absolute = [self absoluteUrlWithPath:url];
    AFHTTPSessionManager* manager = [self LYManagerWithHead:nil];
    LYURLSessionTask* session = [manager POST:url
                                    parameters:parameters
                     constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
                         for (UIImage *image in images) {
                             CGFloat compression = 0.9f;
                             CGFloat maxCompression = 0.1f;
                             NSData* imageData = UIImageJPEGRepresentation(image, compression);
                             while ([imageData length] > 1.0 * 1024 * 1024 &&
                                    compression > maxCompression) {
                                 compression -= 0.1;
                                 imageData = UIImageJPEGRepresentation(image, compression);
                             }
                             debug_NOFileLog(@"❤️❤️❤️的上传图片的尺寸大小%"
                                             @"zd❤️❤️❤️",
                                             [imageData length]);
                             NSString* imageFileName = filename;
                             if (!filename) {
                                 NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                                 formatter.dateFormat = @"yyyyMMddHHmmss";
                                 NSString* str = [formatter stringFromDate:[NSDate date]];
                                 imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
                             }
                             NSLog(@"fileName:%@ file:%@",imageFileName,name);
                             [formData appendPartWithFileData:imageData
                                                         name:name ?: @"file"
                                                     fileName:imageFileName
                                                     mimeType:mineType ?: @"Multipart-form-data"];
                         }
                     }
                                  
                                      progress:^(NSProgress* _Nonnull uploadProgress) {
                                          // TODO: 这里显示进度
                                      }
                                       success:^(NSURLSessionDataTask* _Nonnull task,
                                                 id _Nullable responseObject) {
                                           [[self allRequestTaks] removeObject:task];
                                           [self successResponse:responseObject callback:success];
                                           if (ly_EnableInterfaceDebug) {
                                               [self logWithSuccessrequestHead:nil Response:responseObject url:absolute params:parameters];
                                           }
                                       }
                                       failure:^(NSURLSessionDataTask* _Nullable task, NSError* _Nonnull error) {
                                           [[self allRequestTaks] removeObject:task];
                                           [self handleCallbackWithError:error fail:fail url:url];
                                           if (ly_EnableInterfaceDebug) {
                                               [self logWithFailError:error url:absolute params:parameters];
                                           }
                                       }];
    //存到请求数组中
    [session resume];
    if (session) {
        [[self allRequestTaks] addObject:session];
    }
    return session;
    
}

//文件下载和上传
+ (LYURLSessionTask*)uploadFileWithUrl:(NSString*)url
                          uploadingFile:(NSString*)uploadingFile
                               progress:(LYUpdateProgress)progress
                                success:(LYRespondSuccess)success
                                   fail:(LYRespondFail)fail {
    NSString* absolute;
    if (ly_encodeUTF8) {
        absolute = [self encodeUTF8Url:url];
    } else {
        absolute = url;
    }
    
    if ([NSURL URLWithString:uploadingFile] == nil) {
        debug_NOFileLog(
                        @"uploadingFile无效，无法生成URL。请检查待上传文件是否存在");
        return nil;
    }
    
    NSURL* uploadURL = nil;
    if (ly_NetworkBaseUrl == nil) {
        uploadURL = [NSURL URLWithString:absolute];
    } else {
        uploadURL = [NSURL
                     URLWithString:[NSString stringWithFormat:@"%@%@", ly_NetworkBaseUrl,
                                    absolute]];
    }
    if (uploadURL == nil) {
        debug_NOFileLog(@"URLString无效，无法生成URL。可能是URL中有中文或特殊字符，"
                        @"请尝试Encode URL");
        return nil;
    }
    
    AFHTTPSessionManager* manager = [self LYManagerWithHead:nil];
    NSURLRequest* request = [NSURLRequest requestWithURL:uploadURL];
    LYURLSessionTask* session = nil;
    
    [manager uploadTaskWithRequest:request
                          fromFile:[NSURL URLWithString:uploadingFile]
                          progress:^(NSProgress* _Nonnull uploadProgress) {
                              if (progress) {
                                  progress(uploadProgress.completedUnitCount,
                                           uploadProgress.totalUnitCount);
                              }
                          }
                 completionHandler:^(NSURLResponse* _Nonnull response,
                                     id _Nullable responseObject,
                                     NSError* _Nullable error) {
                     [[self allRequestTaks] removeObject:session];
                     
                     [self successResponse:responseObject callback:success];
                     
                     if (error) {
                         [self handleCallbackWithError:error fail:fail url:url];
                         if (ly_EnableInterfaceDebug) {
                             [self logWithFailError:error
                                                url:response.URL.absoluteString
                                             params:nil];
                         }
                     } else {
                         if (ly_EnableInterfaceDebug) {
                             [self logWithSuccessrequestHead:nil Response:responseObject url:response.URL.absoluteString params:nil];
                         }
                     }
                 }];
    
    if (session) {
        [[self allRequestTaks] addObject:session];
    }
    return session;
}

+ (LYURLSessionTask*)downloadWithUrl:(NSString*)url
                           saveToPath:(NSString*)saveToPath
                             progress:(LYDownLoadProgress)progressBlock
                              success:(LYRespondSuccess)success
                              failure:(LYRespondFail)failure {
    NSString* absolute;
    if (ly_encodeUTF8) {
        absolute = [self encodeUTF8Url:url];
    } else {
        absolute = url;
    }
    
    if (ly_NetworkBaseUrl == nil) {
        if ([NSURL URLWithString:url] == nil) {
            debug_NOFileLog(
                            @"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                  ly_NetworkBaseUrl,
                                  url]] == nil) {
            debug_NOFileLog(
                            @"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    NSURLRequest* downloadRequest =
    [NSURLRequest requestWithURL:[NSURL URLWithString:absolute]];
    AFHTTPSessionManager* manager = [self LYManagerWithHead:nil];
    
    LYURLSessionTask* session = nil;
    session = [manager downloadTaskWithRequest:downloadRequest
                                      progress:^(NSProgress* _Nonnull downloadProgress) {
                                          if (progressBlock) {
                                              progressBlock(downloadProgress.completedUnitCount,
                                                            downloadProgress.totalUnitCount);
                                          }
                                      }
                                   destination:^NSURL* _Nonnull(NSURL* _Nonnull targetPath,
                                                                NSURLResponse* _Nonnull response) {
                                       return [NSURL fileURLWithPath:saveToPath];
                                   }
                             completionHandler:^(NSURLResponse* _Nonnull response,
                                                 NSURL* _Nullable filePath, NSError* _Nullable error) {
                                 [[self allRequestTaks] removeObject:session];
                                 
                                 if (error == nil) {
                                     if (success) {
                                         success(filePath.absoluteString);
                                     }
                                     
                                     if (ly_EnableInterfaceDebug) {
                                         debug_NOFileLog(@"Download success for url %@",
                                                         [self absoluteUrlWithPath:url]);
                                     }
                                 } else {
                                     [self handleCallbackWithError:error fail:failure url:url];
                                     
                                     if (ly_EnableInterfaceDebug) {
                                         debug_NOFileLog(@"Download fail for url %@, reason : %@",
                                                         [self absoluteUrlWithPath:url],
                                                         [error description]);
                                     }
                                 }
                             }];
    
    [session resume];
    if (session) {
        [[self allRequestTaks] addObject:session];
    }
    return session;
}


#pragma mark -
#pragma mark 私有方法

+ (LYURLSessionTask*)_requestWithUrl:(NSString*)url
                             headDict:(NSDictionary*)header
                         refreshCache:(BOOL)refreshCache
                            httpMedth:(NSUInteger)httpMethod
                               params:(NSDictionary*)params
                             progress:(LYDownLoadProgress)progress
                              success:(LYRespondSuccess)success
                                 fail:(LYRespondFail)fail {
    AFHTTPSessionManager* manager = [self LYManagerWithHead:header];
    
    NSString* absoStr = [self absoluteUrlWithPath:url];
    
    NSString* absolute;
    
    if (ly_encodeUTF8) {
        absolute = [self encodeUTF8Url:absoStr];
    } else {
        absolute = absoStr;
    }
    
    //*****************（现在接口有点问题）
    if (ly_NetworkBaseUrl == nil) {
        if ([NSURL URLWithString:absolute] == nil) {
            debug_NOFileLog(
                            @"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    } else {
        NSURL* absouluteURL = [NSURL URLWithString:absolute];
        if (absouluteURL == nil) {
            debug_NOFileLog(
                            @"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    if (ly_autoEncode) {
        absolute = [self encodeUrl:absolute];
    }
    
    LYURLSessionTask* session = nil;
    if (httpMethod == 1) {  // GET请求方式
        session = [manager GET:absolute
                    parameters:params
                      progress:^(NSProgress* _Nonnull downloadProgress) {  //请求进度
                          if (progress) {
                              progress(downloadProgress.completedUnitCount,
                                       downloadProgress.totalUnitCount);
                          }
                      }
                       success:^(NSURLSessionDataTask* _Nonnull task,
                                 id _Nullable responseObject) {
                           [self successResponse:responseObject callback:success];
                           if (ly_cacheGet) {
                               [self cacheResponseObject:responseObject
                                                 request:task.currentRequest
                                              parameters:params];
                           }
                           [[self allRequestTaks] removeObject:task];
                           if (ly_EnableInterfaceDebug) {
                               [self logWithSuccessrequestHead:nil Response:responseObject url:absolute params:params];
                           }
                       }
                       failure:^(NSURLSessionDataTask* _Nullable task,
                                 NSError* _Nonnull error) {
                           [[self allRequestTaks] removeObject:task];
                           if (ly_gainCache) {
                               id response =
                               [LYNetRequestManager chaceRequestWithURL:task.currentRequest
                                                               params:params];
                               if (response) {
                                   [self successResponse:response callback:success];
                               } else {
                                   [self handleCallbackWithError:error fail:fail url:url];
                               }
                           } else {
                               [self handleCallbackWithError:error fail:fail url:url];
                           }
                           if (ly_EnableInterfaceDebug) {
                               [self logWithFailError:error url:absolute params:params];
                           }
                       }];
        
    } else {  // POST请求
        session = [manager POST:url
                     parameters:params
                       progress:^(NSProgress* _Nonnull uploadProgress) {
                           if (progress) {
                               progress(uploadProgress.completedUnitCount,
                                        uploadProgress.totalUnitCount);
                           }
                       }
                        success:^(NSURLSessionDataTask* _Nonnull task,
                                  id _Nullable responseObject) {
                            //            NSHTTPURLResponse *respon =(NSHTTPURLResponse *) task.response;
                            //            NSDictionary *allHeaders = respon.allHeaderFields;
                            
                            NSDictionary * requestDict = task.currentRequest.allHTTPHeaderFields;
                            
                            [self successResponse:responseObject callback:success];
                            if (ly_cachePost) {
                                [self cacheResponseObject:responseObject
                                                  request:task.currentRequest
                                               parameters:params];
                            }
                            [[self allRequestTaks] removeObject:task];
                            if (ly_EnableInterfaceDebug) {
                                [self logWithSuccessrequestHead:requestDict Response:responseObject
                                                            url:absolute
                                                         params:params];
                            }
                            
                        }
                        failure:^(NSURLSessionDataTask* _Nullable task,
                                  NSError* _Nonnull error) {
                            if (ly_gainCache) {
                                id response =
                                [LYNetRequestManager chaceRequestWithURL:task.currentRequest
                                                                params:params];
                                if (response) {
                                    [self successResponse:response callback:success];
                                } else {
                                    [self handleCallbackWithError:error fail:fail url:url];
                                }
                            } else {
                                [self handleCallbackWithError:error fail:fail url:url];
                            }
                            [[self allRequestTaks] removeObject:task];
                            if (ly_EnableInterfaceDebug) {
                                [self logWithFailError:error url:absolute params:params];
                            }
                        }];
    }
    //******加入到请求数组中
    if (session) {
        [[self allRequestTaks] addObject:session];
    }
    return session;
}

//对地址进行编码
+ (NSString*)encodeUrl:(NSString*)url {
    return [self hybURLEncode:url];
}


+ (NSString*)hybURLEncode:(NSString*)url {
    NSString* newString =
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                              kCFAllocatorDefault, (CFStringRef)url, NULL,
                                                              CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
                                                              CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    if (newString) {
        return newString;
    }
    
    return url;
}

//请求成功后回调
+ (void)successResponse:(id)responseData callback:(LYRespondSuccess)success {
    if (success) {
        success([self tryToParseData:responseData]);
    }
}

//请求失败回调
+ (void)handleCallbackWithError:(NSError*)error fail:(LYRespondFail)fail url:(NSString *)url{
    if ([error code] == NSURLErrorCancelled) {  //请求取消
        if (ly_cancelCallBlack) {
            if (fail) {
                fail(error);
            }
        }
    } else {
        if (fail) {
            fail(error);
            
//            NSError *aError = error;
//            if ([url isEqualToString:@"http://114.215.27.196:8675/Aigo/find/find.do"] || [url isEqualToString:@"http://114.215.27.196:8675/Aigo/user/selectMyself.do"]) {
//                
//            }else{
//                
//                if ((long)[aError code] == -1009) {
////                    HUDNormal1(@"断网啦,请检查网络连接");
//                }else{
////                    HUDNormal(@"请求失败");
//                }
//                
//            }
            
        }
    }
}

//请求数据解析成JSON
+ (id)tryToParseData:(id)responseData {
    if ([responseData isKindOfClass:[NSData class]]) {
        // 尝试解析成JSON
        if (responseData == nil) {
            return responseData;
        } else {
            NSError* error = nil;
            NSDictionary* response =
            [NSJSONSerialization JSONObjectWithData:responseData
                                            options:NSJSONReadingMutableContainers
                                              error:&error];
            
            if (error != nil) {
                return responseData;
            } else {
                return response;
            }
        }
    } else {
        return responseData;
    }
}

//输出成功信息
+ (void)logWithSuccessrequestHead:(id)requestHead  Response:(id)response
                              url:(NSString*)url
                           params:(NSDictionary*)params{
    debug_NOFileLog(@"\n");
    debug_NOFileLog(@"\nRequest success,requestHead:%@ \nURL: %@\n params:%@\n response:%@\n,\n",requestHead,
                    [self generateGETAbsoluteURL:url params:params], params,
                    [self tryToParseData:response]);
}

//输出失败信息
+ (void)logWithFailError:(NSError*)error url:(NSString*)url params:(id)params {
    NSString* format = @" params: ";
    if (params == nil || ![params isKindOfClass:[NSDictionary class]]) {
        format = @"";
        params = @"";
    }
    debug_NOFileLog(@"\n");
    if ([error code] == NSURLErrorCancelled) {
        debug_NOFileLog(@"\nRequest was canceled mannully, URL: %@ %@%@\n\n",
                        [self generateGETAbsoluteURL:url params:params], format,
                        params);
    } else {
        debug_NOFileLog(@"\nRequest error, URL: %@ %@%@\n errorInfos:%@\n\n",
                        [self generateGETAbsoluteURL:url params:params], format,
                        params, [error localizedDescription]);
    }
}

// 仅对一级字典结构起作用
+ (NSString*)generateGETAbsoluteURL:(NSString*)url params:(id)params {
    if (params == nil || ![params isKindOfClass:[NSDictionary class]] ||
        [params count] == 0) {
        return url;
    }
    
    NSString* queries = @"";
    for (NSString* key in params) {
        id value = [params objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            continue;
        } else if ([value isKindOfClass:[NSArray class]]) {
            continue;
        } else if ([value isKindOfClass:[NSSet class]]) {
            continue;
        } else {
            queries = [NSString
                       stringWithFormat:@"%@%@=%@&", (queries.length == 0 ? @"&" : queries),
                       key, value];
        }
    }
    
    if (queries.length > 1) {
        queries = [queries substringToIndex:queries.length - 1];
    }
    
    if (([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) &&
        queries.length > 1) {
        if ([url rangeOfString:@"?"].location != NSNotFound ||
            [url rangeOfString:@"#"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@%@", url, queries];
        } else {
            queries = [queries substringFromIndex:1];
            url = [NSString stringWithFormat:@"%@?%@", url, queries];
        }
    }
    return url.length == 0 ? queries : url;
}

//获取缓存数据
+ (id)chaceRequestWithURL:(NSURLRequest*)url params:(id)params {
    id chaceData = nil;
    NSString* directoryPath = cacheNetworkPath();
    if (url) {
        NSString* absoluteURL =
        [self generateGETAbsoluteURL:url.URL.absoluteString params:params];
        NSString* key = absoluteURL.md5CodeStr;
        NSString* path = [directoryPath stringByAppendingPathComponent:key];
        NSData* date = [[NSFileManager defaultManager] contentsAtPath:path];
        if (date) {
            chaceData = [NSKeyedUnarchiver unarchiveObjectWithData:date];
        }
    }
    return chaceData;
}

//缓存请求数据
+ (void)cacheResponseObject:(id)responseObject
                    request:(NSURLRequest*)request
                 parameters:(id)params {
    if (request && responseObject &&
        ![responseObject isKindOfClass:[NSNull class]]) {
        NSString* directoryPath = cacheNetworkPath();
        
        NSError* error = nil;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath
                                                  isDirectory:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            if (error) {
                debug_NOFileLog(@"create cache dir error: %@\n", error);
                return;
            }
        }
        NSString* absoluteURL =
        [self generateGETAbsoluteURL:request.URL.absoluteString params:params];
        NSString* key = absoluteURL.md5CodeStr;
        NSString* path = [directoryPath stringByAppendingPathComponent:key];
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:responseObject];
        if (data && error == nil) {
            BOOL isOk = [[NSFileManager defaultManager] createFileAtPath:path
                                                                contents:data
                                                              attributes:nil];
            if (isOk) {
                debug_NOFileLog(@"cache file ok for request: %@\n", absoluteURL);
            } else {
                debug_NOFileLog(@"cache file error for request: %@\n", absoluteURL);
            }
        }
    }
}

//获取绝对路径
+ (NSString*)absoluteUrlWithPath:(NSString*)path {
    if (path == nil || path.length == 0) {
        return @"";
    }
    if (ly_NetworkBaseUrl == nil || [ly_NetworkBaseUrl length] == 0) {
        return path;
    }
    NSString* absoluteUrl = path;
    if (![path hasPrefix:@"http://"] && ![path hasPrefix:@"https://"]) {
        if ([ly_NetworkBaseUrl hasSuffix:@"/"]) {
            if ([path hasPrefix:@"/"]) {
                NSMutableString* mutablePath = [NSMutableString stringWithString:path];
                [mutablePath deleteCharactersInRange:NSMakeRange(0, 1)];
                absoluteUrl = [NSString
                               stringWithFormat:@"%@%@", ly_NetworkBaseUrl, mutablePath];
            } else {
                absoluteUrl =
                [NSString stringWithFormat:@"%@%@", ly_NetworkBaseUrl, path];
            }
        } else {
            
            if ([path hasPrefix:@"/"]) {
                absoluteUrl =
                [NSString stringWithFormat:@"%@%@", ly_NetworkBaseUrl, path];
            } else {
                absoluteUrl =
                [NSString stringWithFormat:@"%@/%@", ly_NetworkBaseUrl, path];
            }
        }
    }
    
    return absoluteUrl;
}

//对URL进行UTF8编码
+ (NSString*)encodeUTF8Url:(NSString*)url {
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

//设置请求头
+ (AFHTTPSessionManager*)LYManagerWithHead:(NSDictionary*)header {
    //开启转圈
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager* manager = nil;
    if (ly_NetworkBaseUrl != nil) {
        manager = [[AFHTTPSessionManager alloc]
                   initWithBaseURL:[NSURL URLWithString:ly_NetworkBaseUrl]];
    } else {
        manager = [AFHTTPSessionManager manager];
    }
    
    switch (ly_RequesetType) {
        case LYRequestTypeJSON: {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        }
        case LYRequestTypePlainText: {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        }
        case LYRequestTypePlist: {
            manager.requestSerializer = [AFPropertyListRequestSerializer serializer];
            break;
        }
            
        default: { break; }
    }
    
    switch (ly_ResponseType) {
        case LYResponseTypeJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case LYResponseTypeXML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
        case LYResponseTypedData: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        case LYResponseTypePlist:
            manager.responseSerializer =
            [AFPropertyListResponseSerializer serializer];
            break;
        default: { break; }
    }
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    for (NSString* key in header.allKeys) {
        if (header[key] != nil) {
            [manager.requestSerializer setValue:header[key] forHTTPHeaderField:key];
        }
    }
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
                                                                              @"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"
                                                                              ]];
    
    manager.requestSerializer.timeoutInterval = ly_timeOut;
    // 设置允许同时最大并发数量，过大容易出问题
    manager.operationQueue.maxConcurrentOperationCount = 3;
    
    return manager;
}


@end
