//
//  LYNetRequestManager.h
//  CommontCateGory
//
//  Created by liying on 17/8/18.
//  Copyright © 2017年 liying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 下载进度

 @param bytesRead 已下载的大小
 @param totalBytesdRead 下载文件的总大小
 */
typedef void (^LYDownLoadProgress)(ino64_t bytesRead, int64_t totalBytesdRead);

typedef LYDownLoadProgress LYGetProgress;
typedef LYDownLoadProgress LYPostProgress;


/**
 上传文件进度
 @param batesWritten   已上传文件大小
 @param totalBytesWritten 总文件大小
 */
typedef void (^LYUpdateProgress)(ino64_t batesWritten, ino64_t totalBytesWritten);


/**
 @author liying
 响应类型
 */
typedef NS_ENUM(NSInteger, LYResponseType){
    /**
     默认JSON
     */
    LYResponseTypeJSON = 0,
    /**
     XML（只能返回XMLParser,还需要自己通过代理方法解析）
     */
    LYResponseTypeXML,
    /**
     二进制数据
     */
    LYResponseTypedData,
    /**
     PList格式
     */
    LYResponseTypePlist,
};


/**
 @author liying
 请求类型
 */
typedef NS_ENUM(NSInteger, LYRequestType) {
    /**
     默认（JSON）
     */
    LYRequestTypeJSON = 0,
    /**
     普通text/html(二进制格式)
     */
    LYRequestTypePlainText,
    /**
     Plist格式
     */
    LYRequestTypePlist,
};

@class NSURLSessionTask;

typedef NSURLSessionTask LYURLSessionTask;
typedef void (^LYRespondSuccess)(id respond);
typedef void (^LYRespondFail)(NSError* error);

/**
 @author liying
 
 基于AFNetwork3.0 -bate2.0
 */
@interface LYNetRequestManager : NSObject

#pragma mark -
#pragma mark 基础参数配置
/**
 @author liying
 
 设置baseUrl
 */
+ (void)networkBaseUrl:(NSString*)baseUrl;

/**
 @author liying
 
 设置请求超时时间 默认为20s
 */
+ (void)setRequestTimeOut:(NSTimeInterval)timeout;

/**
 @author liying
 
 打开Debug调试信息输出
 */
+ (void)openDebugModel:(BOOL)openDebug;

/**
 @author liying
 
 配置请求格式，
 @param requestType 默认为JSON
 @param responseType	默认JSON
 @param shouldAutoEncode 是否自动进行encode URL 默认为NO
 @param shouldCallbackOnCancelRequest	请求取消时是否回调失败Block 默认为YES
 */

+ (void)configRequestType:(LYRequestType)requestType
             responseType:(LYResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
  callbackOnCancelRequest:(BOOL)shouldCallbackOnCancelRequest;

/**
 是否对网址进行UTF8编码 默认为YES
 @param encode
 */
+ (void)encodeUrlToUTF8:(BOOL)encode;

#pragma mark -
#pragma mark 请求数据缓存

/**
 @author liying
 
 在请求失败时是否从缓存中获取数据 默认为NO
 */
+ (void)gainDataFromLocalWhenNetworkUnconnected:(BOOL)shouldGain;

/**
 @author liying
 
 默认只缓存GET请求的数据，对于POST请求是不缓存的。
 
 @param isCacheGet	默认为YES
 @param cachePost	默认为NO
 */

+ (void)cacheGetRequest:(BOOL)isCacheGet CachePost:(BOOL)cachePost;

/**
 @author liying
 
 总共缓存大小 ,单位：bytes
 @return  缓存大小
 */
+ (unsigned long long)totalCacheSize;

/**
 @author liying
 
 清除所有缓存
 */

+ (void)clearCache;

#pragma mark -
#pragma mark 取消网络请求

/**
 @author liying
 
 取消所有请求
 */
+ (void)cancelAllRequest;

/**
 @author liying
 
 根据URL来取消某个特定的请求
 @param url	可以是绝对URL，也可以是path（不包括baseurl）
 */

+ (void)cancelRequestWithURL:(NSString*)url;

#pragma mark -
#pragma mark Get&&POST请求
/**
 @author liying
 
 GET请求接口，若不指定baseurl，可传完整的url
 
 @param url	接口路径
 @param header 请求头字典， 没有时可以传空：nil
 @param refreshCache	是否刷新缓存
 @param success	 成功回调
 @param fail	失败回调
 @return 返回对应对象，可用于取消这个请求
 */


+ (LYURLSessionTask*)getWithUrl:(NSString*)url
                        headDict:(NSDictionary*)header
                    refreshCache:(BOOL)refreshCache
                         success:(LYRespondSuccess)success
                            fail:(LYRespondFail)fail;

// 多一个params参数
+ (LYURLSessionTask*)getWithUrl:(NSString*)url
                        headDict:(NSDictionary*)header
                    refreshCache:(BOOL)refreshCache
                          params:(NSDictionary*)params
                         success:(LYRespondSuccess)success
                            fail:(LYRespondFail)fail;

// 多一个带进度回调
+ (LYURLSessionTask*)getWithUrl:(NSString*)url
                        headDict:(NSDictionary*)header
                    refreshCache:(BOOL)refreshCache
                          params:(NSDictionary*)params
                        progress:(LYGetProgress)progress
                         success:(LYRespondSuccess)success
                            fail:(LYRespondFail)fail;

//************************

/**
 
 
 POST接口请求  若不指定baseurl，可传完整的url
 @param url   url
 @param header	请求头， 没有可以传空:nil
 @param refreshCache	是否刷新缓存数据
 @param params	 请求体参数
 @param success	 成功回调
 @param fail	失败回调
 @return  返回对应的请求对象，可用取消对应网络请求
 
 */

+ (LYURLSessionTask*)postWithUrl:(NSString*)url
                         headDict:(NSDictionary*)header
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary*)params
                          success:(LYRespondSuccess)success
                             fail:(LYRespondFail)fail;

//多了一个进度回调
+ (LYURLSessionTask*)postWithUrl:(NSString*)url
                         headDict:(NSDictionary*)header
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary*)params
                         progress:(LYPostProgress)progress
                          success:(LYRespondSuccess)success
                             fail:(LYRespondFail)fail;

#pragma mark -
#pragma mark 图片，文件下载上传

/**
 @author liying
 
 图片上传参数
 @param image	图片对象
 @param url   上传路径
 @param filename	给图片起一个名字，默认为当前日期时间,格式为"yyyyMMddHHmmss"，后缀为`jpg`
 @param name	 与指定的图片相关联的名称，这是由后端写接口指定的
 @param mineType	数据类型 默认为image/jpeg
 @param parameters	带请求参数
 @param success     成功回调
 @param fail        失败回调
 @return            返回对应对象
 */

+ (LYURLSessionTask*)uploadWithImage:(UIImage*)image
                                  url:(NSString*)url
                             fileName:(NSString*)filename
                                 name:(NSString*)name
                              mimeTpe:(NSString*)mineType
                           parameters:(NSDictionary*)parameters
                              success:(LYRespondSuccess)success
                                 fail:(LYRespondFail)fail;

/**
 图片上传参数
 @param images	图片对象数组
 @param url   上传路径
 @param filename	给图片起一个名字，默认为当前日期时间,格式为"yyyyMMddHHmmss"，后缀为`jpg`
 @param name	 与指定的图片相关联的名称，这是由后端写接口指定的
 @param mineType	数据类型 默认为image/jpeg
 @param parameters	带请求参数
 @param success     成功回调
 @param fail        失败回调
 @return            返回对应对象
 */

+ (LYURLSessionTask*)uploadWithImageArr:(NSArray*)images
                                     url:(NSString*)url
                                fileName:(NSString*)filename
                                    name:(NSString*)name
                                 mimeTpe:(NSString*)mineType
                              parameters:(NSDictionary*)parameters
                                 success:(LYRespondSuccess)success
                                    fail:(LYRespondFail)fail;

/**
 @author liying
 
 上传文件操作
 @param url  路径
 @param uploadingFile	上传文件的本地路径
 @param progress  上传进度
 @param success   上传成功回调
 @param fail	  上传失败回调
 @return   返回对应对象
 */

+ (LYURLSessionTask*)uploadFileWithUrl:(NSString*)url
                          uploadingFile:(NSString*)uploadingFile
                               progress:(LYUpdateProgress)progress
                                success:(LYRespondSuccess)success
                                   fail:(LYRespondFail)fail;

/**
 @author liying
 
 下载文件接口
 @param url	路径
 @param saveToPath	保存文件的本地路径
 @param progressBlock	进度回调
 @param success	下载成功
 @param failure	下载失败
 @return 返回请求对象
 */

+ (LYURLSessionTask*)downloadWithUrl:(NSString*)url
                           saveToPath:(NSString*)saveToPath
                             progress:(LYDownLoadProgress)progressBlock
                              success:(LYRespondSuccess)success
                              failure:(LYRespondFail)failure;

#pragma mark -
#pragma mark*************************END************************


@end
