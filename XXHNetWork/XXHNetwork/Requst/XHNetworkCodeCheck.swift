//
//  XXHNetworkCodeCheck.swift
//  XXHNetWork
//
//  Created by icochu on 2019/10/8.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit

class XHNetworkCodeCheck: NSObject {

    class func checkCode(Code code:NSInteger) -> Bool {
        if code >= -4 && code < 0 {
            print("您的账号已经在其他设备登录，请重新登录")
            return false
        }
        return true
    }
}
