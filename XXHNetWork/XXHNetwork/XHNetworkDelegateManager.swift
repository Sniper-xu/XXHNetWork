//
//  XHNetworkDelegateManager.swift
//  XXHNetWork
//
//  Created by icochu on 2019/10/9.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit

fileprivate let RequestErrorDomain = "com.network.request"

//成功失败的回调
protocol XHNetworkManagerCallBackDelegate:NSObjectProtocol {
    
    func requesApiSuccess(Manager manager:XHNetworkDelegateManager)
    
    func requesApiFailure(Manager manager:XHNetworkDelegateManager)
}
/**********************************************************************/
@objc protocol XHAPIManagerParamSource:NSObjectProtocol {
    @objc func configeApiParams(Manager manager:XHNetworkDelegateManager) -> [String : Any]?
    @objc optional
    func configeApiParamsForMoreData(Manager manager:XHNetworkDelegateManager) -> [String : Any]?
}
/**********************************************************************/
//用于数据改造，把请求的结果数据改造成自己想的
@objc protocol XHAPIDataReformerDelegate:NSObjectProtocol {
    @objc optional
    func reformerData(Manager manager:XHNetworkDelegateManager, ReformData reformData:[String : Any]?)
    
    func reformerData(Manager manager:XHNetworkDelegateManager, FailedReform reformData:[String : Any]?)

}
/**********************************************************************/
//用于数据/参数检测，如果检测返回no则请求会丢到fail的代理里面，并给出XHNetworkErrorTypeNoContent错误
protocol XHAPIManagerValidator:NSObjectProtocol {
    func checkParams(Manager manager:XHNetworkDelegateManager, CorrectParamsData params:[String : Any]?) -> Bool
    func checkCallBackData(Manager manager:XHNetworkDelegateManager,CorrectWithCallBackData data:Any?) ->Bool
}
//获取必须的参数，该代理必须实现否则会崩溃
@objc protocol XHAPIManager:NSObjectProtocol {
    func methodName() -> String
    func requestType() -> String
    func shouldCache() -> Bool
    @objc optional
    func cleanData()
    @objc optional
    func reformParams(Params params:[String : Any]) -> [String : Any]
}
class XHNetworkDelegateManager: NSObject {
    
    weak var callBackDelagate : XHNetworkManagerCallBackDelegate? = nil
    weak var paramSourceDelegate: XHAPIManagerParamSource? = nil
    weak var validatorDelegate: XHAPIManagerValidator? = nil
    weak var childDelegate:XHAPIManager? = nil
    var errorType: XHNetworkErrorType
    var isMoreData:Bool = false
    var requestConfig:XHNetworkRequestConfig?
    var response:XHURLResponse?
    var isLoading: Bool = false
    
    override init() {
        errorType = XHNetworkErrorType.typeDefault
        super.init()
        if self.conforms(to: XHAPIManager.self) {
            self.childDelegate = self as? XHAPIManager
        }else {
            let exception:NSException = NSException(name: NSExceptionName(rawValue: "XHNetworkManager提示"), reason: String("\(self.childDelegate)没有遵循XHAPIManager协议"), userInfo: nil)
            print("\(exception)")
        }
    }
}

extension XHNetworkDelegateManager {
    //MARK:-calling api
    func loadData() {
        let shouldCache = self.childDelegate?.shouldCache()
        let params = self.paramSourceDelegate?.configeApiParams(Manager: self)
        let apiString = self.childDelegate?.methodName()
        let method = self.childDelegate?.requestType()
        requestConfig = XHNetworkRequestConfig(with: method, apiString, params, nil)
        requestConfig?.shouldAllIgnoreCache = !shouldCache!
        //准备好参数，开始请求
        self.requesData(RequesConfig: requestConfig!)
    }
    
    func loadMoreData() {
        let shouldCache = self.childDelegate?.shouldCache()
        let params = self.paramSourceDelegate?.configeApiParamsForMoreData?(Manager: self)
        let apiString = self.childDelegate?.methodName()
        let method = self.childDelegate?.requestType()
        requestConfig = XHNetworkRequestConfig(with: method, apiString, params, nil)
        requestConfig?.shouldAllIgnoreCache = !shouldCache!
        //准备好参数，开始请求
        self.requesData(RequesConfig: requestConfig!)
    }
}

extension XHNetworkDelegateManager {
    fileprivate func requesData(RequesConfig requestConfig:XHNetworkRequestConfig) {
        //判断是否需要拦截请求 检验参数是否合理
        if (self.validatorDelegate?.checkParams(Manager: self, CorrectParamsData: requestConfig.params))! {
            //正确
            if requestConfig.shouldAllIgnoreCache {
                //忽略缓存，进行网络请求
                self.isLoading = true
                self.requesNetwork(RequestConfig: requestConfig)
            }else {
                //从缓存中找数据
                XHNetworkCacheManager.shared.findCache(NetworkRequestConfig: requestConfig, SuccessBlock: { (successResponse) in
                    //缓存查找成功
                }) { (failResponse) in
                    //缓存查找失败，进行网络请求
                    self.isLoading = true
                    self.requesNetwork(RequestConfig: requestConfig)
                }
            }
        }else {
            //参数出错
            let response:XHURLResponse = XHURLResponse(with: requestConfig)
            self.requesApiFailure(response, XHNetworkErrorType.typeParamsError)
        }
        if requestConfig.shouldAllIgnoreCache {
            //忽略缓存，直接网络请求
            self.requesNetwork(RequestConfig: requestConfig)
        }else {
            //从缓存中找数据
            XHNetworkCacheManager.shared.findCache(NetworkRequestConfig: requestConfig, SuccessBlock: { (successResponse) in
                //查找到，拿出数据
                self.requesApiSuccess(successResponse)
            }) { (failResponse) in
                //缓存查找失败，进行网络请求
                self.requesNetwork(RequestConfig: requestConfig)
            }
        }
    }
    
    fileprivate func requesNetwork(RequestConfig requsetConfig:XHNetworkRequestConfig) {
        if XHNetworkConfigution.shared.isReachable {
            XHApiProxy.shared.callNetwork(with: requsetConfig, { (successResponse) in
                self.requesApiSuccess(successResponse)
            }) { (failResponse) in
                self.requesApiFailure(failResponse, XHNetworkErrorType.typeDefault)
            }
        }else {
            //无网络,直接给出错误
            let response:XHURLResponse = XHURLResponse(with: requsetConfig)
            self.requesApiFailure(response, XHNetworkErrorType.typeNoNetwork)
            //提示无网络
        }
    }
    
    fileprivate func checkData(_ response:XHURLResponse) {
        if (self.validatorDelegate?.checkCallBackData(Manager: self, CorrectWithCallBackData:response.content))! {
            //返回数据合法
            self.callBackDelagate?.requesApiSuccess(Manager: self)
        }else {
            //检测返回数据不合法
            XHNetworkCacheManager.shared.deleteCacheObject(response.requesConfig)
            self.requesApiFailure(response, XHNetworkErrorType.typeNoContent)
        }
    }
}

extension XHNetworkDelegateManager {
    func requesApiSuccess(_ response:XHURLResponse) {
        //成功拿到数据后
        self.isLoading = false
        self.response = response
        //去检测数据
        self.checkData(response)
    }
    func requesApiFailure(_ response:XHURLResponse, _ errorType:XHNetworkErrorType) {
        self.response = response
        self.isLoading = false
        self.errorType = errorType
        var failureError:NSError?
        switch errorType {
        case .typeParamsError:
            failureError = XHNetworkHelper.getError(Domain: RequestErrorDomain, Info: "--------failed:请求的参数错误------", Code: errorType.rawValue)
        case .typeNoNetwork:
            failureError = XHNetworkHelper.getError(Domain: RequestErrorDomain, Info: "--------failed:暂无网络，请检查------", Code: errorType.rawValue)
        case .typeNoContent:
            failureError = XHNetworkHelper.getError(Domain: RequestErrorDomain, Info: "--------failed:返回的数据不合法------", Code: errorType.rawValue)
        default:
            failureError = XHNetworkHelper.getError(Domain: RequestErrorDomain, Info: "--------failed:暂无网络，请检查------", Code: errorType.rawValue)
        }
        //默认的错误在底部API已处理过
        if errorType != XHNetworkErrorType.typeDefault {
            self.response?.errorType = errorType
            self.response?.error = failureError
        }
        self.callBackDelagate?.requesApiFailure(Manager: self)
    }
}


