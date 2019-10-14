//
//  ViewController.swift
//  XXHNetWork
//
//  Created by icochu on 2019/9/20.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit

class ViewController: UIViewController,XHNetworkManagerCallBackDelegate,XHAPIManagerParamSource {
   
    
    lazy var testManager:XHNetworkTestManager = {
        
        let testManager = XHNetworkTestManager()
        testManager.callBackDelagate = self
        testManager.paramSourceDelegate = self
        return testManager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let params = [String : Any]()
        XHNetworkBlockManager.shared.request(Method: XHNetworkRequestType.get, APIString: "", Parameters: params, SuccessBlock: { (successResponse) in
            print("--------------方式一（block形式）请求数据成功----------")
            self.testManager.loadData()
        }) { (failureResponse) in
            print("--------------方式一请求数据失败----------")
        }
    }


}

extension ViewController {
    func configeApiParams(Manager manager: XHNetworkDelegateManager) -> [String : Any]? {
        
        let dic = [String : Any]()
        return dic
    }
    
    func requesApiSuccess(Manager manager: XHNetworkDelegateManager) {
        print("--------------方式二（delegate形式）请求数据成功----------")
    }
    
    func requesApiFailure(Manager manager: XHNetworkDelegateManager) {
        print("--------------方式二请求数据失败----------")
    }
}
