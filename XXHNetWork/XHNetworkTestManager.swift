//
//  XHNetworkTestManager.swift
//  XXHNetWork
//
//  Created by icochu on 2019/10/11.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit

class XHNetworkTestManager: XHNetworkDelegateManager,XHAPIManager,XHAPIManagerValidator {
//    func reformParams(Params params: [String : Any]) -> [String : Any] {
//        
//    }
    override init() {
        super.init()
        self.validatorDelegate = self
    }
    //请求方法名字，不包含基本地址
    func methodName() -> String {
//        return "schedule/list"
        return ""
    }
    //请求类型
    func requestType() -> String {
        return XHNetworkRequestType.get.rawValue
    }
    //控制是否需要缓存
    func shouldCache() -> Bool {
        return true
    }
    
    //这个代理可以用来检测参数，例如手机号码必须为11位等...如果不符合要求返回false，请求自动回终止，自动到requesApiFailure里面
    func checkParams(Manager manager: XHNetworkDelegateManager, CorrectParamsData params: [String : Any]?) -> Bool {
        return true
    }
    
    //这个代理可以用来返回数据，例如如果判断返回数据不是字典类型，那么直接返回false，请求自动终止，自动到requesApiFailure里面
    func checkCallBackData(Manager manager: XHNetworkDelegateManager, CorrectWithCallBackData data: Any?) -> Bool {
        return true
    }
}
