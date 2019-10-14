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
    
    func methodName() -> String {
//        return "schedule/list"
        return ""
    }
    
    func requestType() -> String {
        return XHNetworkRequestType.get.rawValue
    }
    
    func shouldCache() -> Bool {
        return true
    }
    
    func checkParams(Manager manager: XHNetworkDelegateManager, CorrectParamsData params: [String : Any]?) -> Bool {
        return true
    }
    
    func checkCallBackData(Manager manager: XHNetworkDelegateManager, CorrectWithCallBackData data: Any?) -> Bool {
        return true
    }
}
