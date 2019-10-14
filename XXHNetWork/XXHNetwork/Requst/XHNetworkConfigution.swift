//
//  XHNetworkConfigution.swift
//  XXHNetWork
//
//  Created by icochu on 2019/9/20.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit
import AFNetworking

enum  XHNetworkRequestType : String{
    case get = "GET"
    case pose = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
class XHNetworkConfigution: NSObject {
    
    var baseURLString :String {
        get {
//            return "http://116.62.65.65:38070/coachParentApp/"
            return "https://news-at.zhihu.com/api/4/news/9710114"
        }
    }
    
    // Set the maximum cache limit
    var countLimint :Int = 300
    // Network timeout
    var timeoutInterval:Int = 20
    //Cache version
    var memoryCacheVersion: String?
    // Cache expiration time
    var cacheTimeInSeconds: TimeInterval = 300
    // Request header
    var mutableHTTPRequestHeaders : [String : String]?
    //Whether log printing is enabled
    var dubugLogeEnable:Bool = true
    //Whether SQLLog is enabled
    var SQLLogEnable:Bool = false
    // log password
    var ne_sqlitePassword:String?
    // Set the maximum cache limit
    var ne_saveRequestMaxCount:Int?
    
    var isReachable:Bool {
        get { if  AFNetworkReachabilityManager.shared().networkReachabilityStatus == .notReachable {
                return false
        }else {
            return true
            }
        }
    }
    
    static let shared:XHNetworkConfigution = {
        let help = XHNetworkConfigution()
        return help
    }()
    
    override init() {
        super.init()
    }
}
