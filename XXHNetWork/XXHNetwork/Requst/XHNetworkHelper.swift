//
//  XHNetworkHelper.swift
//  XXHNetWork
//
//  Created by icochu on 2019/9/25.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit

class XHNetworkHelper: NSObject {
    class func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    class func cacheContentOverTime(CacheTime cacheTime:String) -> Bool {
        let nowDate = Date()
        let cacheDate:Date = self.getDate(TimeIntervalString: cacheTime)
        let differenceTime:TimeInterval = nowDate.timeIntervalSince(cacheDate)
        let configCacheTime = XHNetworkConfigution.shared.cacheTimeInSeconds
        
        if Int(differenceTime) > Int(configCacheTime) {
            return true
        }
        return false
    }
    
    //时间转换成时间戳
    class func timeIntervalString(Date date:Date) -> String {
        let timeInterval = date.timeIntervalSince1970
        return String(timeInterval)
    }
    
    class func getDate(TimeIntervalString timeIntervalS:String) -> Date {
        
        let interval = TimeInterval(Int(timeIntervalS)!)
        let date = Date(timeIntervalSince1970: interval)
        return date
    }
    
    class func getError(Domain domain:String, Info info:String, Code code:Int) -> NSError{
        let userInfo = [NSLocalizedDescriptionKey:info]
        let error = NSError.init(domain: domain, code: code, userInfo: userInfo)
        return error
    }
}

