//
//  XHURLResponse.swift
//  XXHNetWork
//
//  Created by icochu on 2019/9/24.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit
enum XHNetworkErrorType:Int {
    //没有产生过API请求，默认状态。
    case typeDefault = -100
    //API请求成功且返回数据正确。
    case typeSuccess = -101
    //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    case typeNoContent = -102
    //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    case typeParamsError = -103
    //请求超时。XHAPIProxy设置的是20秒超时
    case typeTimeout = -104
    //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
    case typeNoNetwork = -105
    //TOKEN被踢下线
    case typeTokenError = -106
    //缓存过期
    case typeCacheExpire = -107
    //缓存数据中app版本过期
    case typeAppVersionExpire = -108
    //缓存数据出错
    case typeCacheDataeError = -109
    
}
class XHURLResponse: NSObject {

    var errorType :XHNetworkErrorType = XHNetworkErrorType.typeDefault
    var contentString:String?
    var content:Any?
    var requestId :Int?
    var request : URLRequest?
    var httpResponse : HTTPURLResponse?
    var responseData : Data?
    var requestParams : [String:Any]?
    var error : NSError?
    var isFormeCache : Bool = false
    var task:URLSessionDataTask?
    var startTime : String?
    var endTime : String?
    var requesConfig:XHNetworkRequestConfig
    
    init(with requesConfig:XHNetworkRequestConfig) {
        self.requesConfig = requesConfig
    }
    
    init(with requesConfig:XHNetworkRequestConfig, _ requestId:Int,_ request:URLRequest) {
        self.requesConfig = requesConfig
        self.requestId = requestId
        self.request = request
        self.requestParams = requesConfig.params
    }
    
    init(with requesConfig:XHNetworkRequestConfig, CacheResponse response:Any?) {
        self.requesConfig = requesConfig
        self.errorType = XHNetworkErrorType.typeSuccess
        self.content = response
        self.requestId = 0
        self.error = nil
        self.isFormeCache = true
    }
    
    func responseStatus(with error:NSError?) -> XHNetworkErrorType {
        if error != nil {
            if(error?.code == NSURLErrorTimedOut) {
                return XHNetworkErrorType.typeTimeout
            }
            return XHNetworkErrorType.typeNoNetwork
        }else {
            return XHNetworkErrorType.typeSuccess
        }
    }
}
