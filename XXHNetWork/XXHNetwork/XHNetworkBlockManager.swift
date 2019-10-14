//
//  XHNetworkBlockManager.swift
//  XXHNetWork
//
//  Created by icochu on 2019/9/25.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit
fileprivate let RequestErrorDomain = "com.network.request"

class XHNetworkBlockManager: NSObject {
    
    static let shared:XHNetworkBlockManager = {
        let share = XHNetworkBlockManager()
        return share
    }()
    
    func request(Method method:XHNetworkRequestType, APIString apiS:String?, Parameters params:[String:Any]?, SuccessBlock success:@escaping XHRequestManagerSuccess, FailureBlock failure:@escaping XHRequestManagerFailure){
        
        let requestConfig:XHNetworkRequestConfig = XHNetworkRequestConfig.init(with: method.rawValue, apiS, params, nil)
        
        self.request(RequestConfig: requestConfig, SuccessBlock: success, FailureBlock: failure)
    }
    
    func request(RequestConfig requsetConfig:XHNetworkRequestConfig, SuccessBlock success:@escaping XHRequestManagerSuccess, FailureBlock failure:@escaping XHRequestManagerFailure) {
        
        if requsetConfig.shouldAllIgnoreCache {
            //忽略缓存，直接网络请求
            self.requesNetwork(RequestConfig: requsetConfig, SuccessBlock: success, FailureBlock: failure)
        }else {
            //从缓存中找数据
            XHNetworkCacheManager.shared.findCache(NetworkRequestConfig: requsetConfig, SuccessBlock: { (successResponse) in
                success(successResponse)
            }) { (failResponse) in
                //缓存查找失败，进行网络请求
                self.requesNetwork(RequestConfig: requsetConfig, SuccessBlock: success, FailureBlock: failure)
            }
        }
    }
    
    func requesNetwork(RequestConfig requsetConfig:XHNetworkRequestConfig, SuccessBlock success:@escaping XHRequestManagerSuccess, FailureBlock failure:@escaping XHRequestManagerFailure) {
        if XHNetworkConfigution.shared.isReachable {
            XHApiProxy.shared.callNetwork(with: requsetConfig, { (successResponse) in
                success(successResponse)
            }) { (failResponse) in
                failure(failResponse)
            }
        }else {
        //无网络,直接给出错误
        let userInfo = [NSLocalizedDescriptionKey:"----Request failed: not network----"]
        let error = NSError.init(domain: RequestErrorDomain, code: XHNetworkErrorType.typeNoNetwork.rawValue, userInfo: userInfo)
        let reponse:XHURLResponse = XHURLResponse.init(with: requsetConfig)
        reponse.errorType = XHNetworkErrorType.typeNoNetwork
        reponse.error = error
        failure(reponse)
        //提示无网络
        }
    }
}
