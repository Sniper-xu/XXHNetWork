//
//  XHNetworkCacheManager.swift
//  XXHNetWork
//
//  Created by icochu on 2019/9/25.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit

fileprivate let RequestCacheErrorDomain = "com.network.request.caching"
fileprivate let NetworknFailingDataErrorDomain = "com.network.error.data"

class XHNetworkCacheManager: NSObject {

    static let shared:XHNetworkCacheManager = {
        let share = XHNetworkCacheManager()
        return share
    }()
    
    func findCache(NetworkRequestConfig requesConfig:XHNetworkRequestConfig,SuccessBlock success:XHRequestManagerSuccess, FailureBlock failure:XHRequestManagerFailure) {
        
        //缓存key
        let cacheKey = self.getCachePath(requesConfig)
        var validationError:NSError? = nil
        //缓存数据是否可用
        let cacheReponse:XHURLResponse? = self.cacheDataAvailable(RequestConfig: requesConfig, cacheKey)
        if cacheReponse != nil {
            //有错误
            failure(cacheReponse!)
        }
        let data : Data? = XHNetworkCacheOperate.shared.getResponseCacheObject(Key: cacheKey) as? Data
        if data == nil {
            let reponse:XHURLResponse = XHURLResponse.init(with: requesConfig)
            validationError = XHNetworkHelper.getError(Domain: RequestCacheErrorDomain, Info: "failed:缓存的为空数据", Code: XHNetworkErrorType.typeCacheDataeError.rawValue)
            reponse.errorType = XHNetworkErrorType.typeCacheDataeError
            reponse.error = validationError
            failure(reponse)
            return
        }
        //有正确数据
        let respondData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        let reposeObject: XHURLResponse = XHURLResponse.init(with: requesConfig, CacheResponse: respondData)
        success(reposeObject)
    }
    
    func storeCacheObject(With object:Any?, _ requesConfig:XHNetworkRequestConfig) {
        
        let cacheKey = self.getCachePath(requesConfig)
        autoreleasepool {
            if let responseData:Data =  try? JSONSerialization.data(withJSONObject: object!, options:.prettyPrinted){
                XHNetworkCacheOperate.shared.setResponseCache(Object:responseData, Key: cacheKey)
                let cacheConfig = cacheConfigModel.init(CacheTime: XHNetworkHelper.timeIntervalString(Date: Date()))
                XHNetworkCacheOperate.shared.setConfigModelCache(Object: cacheConfig, Key: cacheKey)
            }
        }
    }
    
    func deleteCacheObject(_ requesConfig:XHNetworkRequestConfig) {
        let cacheKey = self.getCachePath(requesConfig)
        XHNetworkCacheOperate.shared.removeResponseCacheObject(Key: cacheKey)
        XHNetworkCacheOperate.shared.removeConfigModelCacheObject(Key: cacheKey)
    }
}

extension XHNetworkCacheManager {
    
    fileprivate func getCachePath(_ requesConfig:XHNetworkRequestConfig) -> String {
        let requesString = String(describing: "method:\(String(describing: requesConfig.method)) url:\(String(describing: requesConfig.urlString)) params:\(String(describing: requesConfig.params))")
        return requesString.MD5String()
    }
    
    fileprivate func cacheDataAvailable(RequestConfig requsetConfig:XHNetworkRequestConfig,_ cacheKey:String) -> XHURLResponse? {
        
        let reponse:XHURLResponse = XHURLResponse.init(with: requsetConfig)
        var validationError:NSError? = nil
        let model:cacheConfigModel? = XHNetworkCacheOperate.shared.getConfigModelCacheObject(Key: cacheKey) as? cacheConfigModel
        if model == nil {
            //没有缓存配置文件
            validationError = XHNetworkHelper.getError(Domain: RequestCacheErrorDomain, Info: "----failed: 没有缓冲数据----", Code: XHNetworkErrorType.typeCacheDataeError.rawValue)
            reponse.errorType = XHNetworkErrorType.typeCacheDataeError
            reponse.error = validationError
            return reponse
        }
        //数据是否超时间了
        if XHNetworkHelper.cacheContentOverTime(CacheTime: model!.cacheTime!){
            validationError = XHNetworkHelper.getError(Domain: RequestCacheErrorDomain, Info: "----failed: 缓存数据过期了----", Code: XHNetworkErrorType.typeCacheExpire.rawValue)
            reponse.errorType = XHNetworkErrorType.typeCacheExpire
            reponse.error = validationError
            return reponse
        }
        
        let currentAppVersion = XHNetworkHelper.getAppVersion()
        let cacheAppVersion = model!.appVersion
        if currentAppVersion != cacheAppVersion {
            //数据是否属于当前版本的数据，不属于
            validationError = XHNetworkHelper.getError(Domain: RequestCacheErrorDomain, Info: "----failed: 缓存数据的版本过期----", Code: XHNetworkErrorType.typeAppVersionExpire.rawValue)
            reponse.errorType = XHNetworkErrorType.typeAppVersionExpire
            reponse.error = validationError
            return reponse
        }
        
        if validationError != nil {
            //把这条没用数据删除
            XHNetworkCacheOperate.shared.removeResponseCacheObject(Key: cacheKey)
            XHNetworkCacheOperate.shared.removeConfigModelCacheObject(Key: cacheKey)
        }
        return nil
    }
}
