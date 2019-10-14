//
//  XHNetworkRequestConfig.swift
//  XXHNetWork
//
//  Created by icochu on 2019/9/23.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit

class XHNetworkRequestConfig: NSObject {

    //请求方式
    var method : String?
    //请求地址
    var urlString : String?
    //请求参数
    var params : [String : Any]?
    //请求控制器名字
    var classVCName : String?
    //是否忽略缓存
    var shouldAllIgnoreCache : Bool = true
    //是否需要序列化
    var needSerializer:Bool = false
    
    init(with method:String?, _ APIString:String?, _ params:[String : Any]?, _ classVCName:String?) {
        self.method = method
        
        let baseURLString:String = XHNetworkConfigution.shared.baseURLString
        if let apiString = APIString {
            self.urlString = baseURLString.appending(apiString)
        }else {
            self.urlString = baseURLString
        }
        self.params = params
        self.classVCName = classVCName
    }
}
