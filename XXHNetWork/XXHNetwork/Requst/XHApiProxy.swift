//
//  XXHApiProxy.swift
//  XXHNetWork
//
//  Created by icochu on 2019/9/20.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit
import AFNetworking

typealias XHRequestManagerSuccess = (_ successResponse:XHURLResponse) -> Void
typealias XHRequestManagerFailure = (_ failResponse:XHURLResponse) ->Void
typealias XHRequestManagerProgress = (_ progress:Progress?) ->Void

fileprivate let RequestErrorDomain = "com.network.request"

class XHApiProxy: NSObject {
    var sessionManager : AFHTTPSessionManager?
    var requestDic : [String : XHURLResponse]?
    
    static let shared:XHApiProxy = {
        let share = XHApiProxy()
        share.requestDic = [:]
        return share
    }()
    
    func callNetwork(with requestConfig:XHNetworkRequestConfig, _ successCompletionBlock:@escaping XHRequestManagerSuccess, _ failureCompletionBlock:@escaping XHRequestManagerFailure) {
        
        sessionManager = self.getSessionManager(with: requestConfig)
        var dataTask:URLSessionDataTask?
        guard let request:URLRequest = generateRequest(with: requestConfig) as URLRequest? else { return}
        dataTask = sessionManager!.dataTask(with:request, uploadProgress: nil, downloadProgress: nil, completionHandler: { (response, responseObject, error) in
            
            guard let requestId = dataTask?.taskIdentifier else {return}
            var urlRespose:XHURLResponse? = self.requestDic?[String(requestId)]
            let httpRespose :HTTPURLResponse = response as! HTTPURLResponse

            if urlRespose == nil {
                urlRespose = XHURLResponse(with: requestConfig, requestId, request)
            }
            var dataTip:Any? = responseObject
            if responseObject == nil {
                dataTip = ["data":"后台没有给你返回任何数据，请仔细检查网络是否连接，接口是否存在"]
            }

            var responseString:String?
            var newResposeData:Data?
            if let responseData:Data =  try? JSONSerialization.data(withJSONObject: dataTip!, options:.prettyPrinted){
                newResposeData = responseData
                responseString = String(data: responseData, encoding: .utf8)
            }
            
            if (error != nil) {
                //请求返回
                let repose: XHURLResponse = self.reponseParams(with: urlRespose!, content: dataTip, responseString, error as NSError? ,newResposeData, dataTask,httpRespose)
                //打印日志
                XHNetworkLogManager.shared.logDebugInfo(URLResponse: repose)
                //回调
                failureCompletionBlock(repose)
            }else {
                let repose: XHURLResponse = self.reponseParams(with: urlRespose!, content: dataTip, responseString, nil , newResposeData, dataTask,httpRespose)
                //打印日志
                XHNetworkLogManager.shared.logDebugInfo(URLResponse: repose)
                let responseContent = responseObject as? [String : Any]
                let code = responseContent?["code"] as? Int
                if code != nil {
                    //如果后台返回了code，检测code是否合法
                    if XHNetworkCodeCheck.checkCode(Code: code!)  {
                        //检测code，合法
                        successCompletionBlock(repose)
                        if !requestConfig.shouldAllIgnoreCache {
                            //把数据缓存下
                            XHNetworkCacheManager.shared.storeCacheObject(With: responseObject, requestConfig)
                        }
                    }else {
                        //不合法code
                        let userInfo = [NSLocalizedDescriptionKey:"----failed: code错误----"]
                        let error = NSError.init(domain: RequestErrorDomain, code: code!, userInfo: userInfo)
                        repose.errorType = XHNetworkErrorType.typeTokenError
                        repose.error = error
                        failureCompletionBlock(repose)
                    }
                }else {
                    successCompletionBlock(repose)
                }
            }
            self.requestDic?.removeValue(forKey: String(requestId))
            
        })
        dataTask?.resume()
        self.startLoadRequest(with: request, dataTask, requestConfig)
    }
    
    //取消具体某个请求
    func cancelRequest(with requestId:Int){
        let reponse:XHURLResponse? = self.requestDic?[String(requestId)]
        guard let reponsed = reponse else { return }
        let requestOperation:URLSessionDataTask? = reponsed.task
        requestOperation?.cancel()
        self.requestDic?.removeValue(forKey: String(requestId))
    }
    //取消全部请求
    func cancelAllRequest() {
        guard let requestDic = self.requestDic else { return}
        for key in requestDic.keys {
            self.cancelRequest(with: Int(key)!)
        }
    }
}

extension XHApiProxy {
    
    fileprivate func getSessionManager(with configution: XHNetworkRequestConfig) -> AFHTTPSessionManager {
        let sessionManager : AFHTTPSessionManager = AFHTTPSessionManager.init(sessionConfiguration: URLSessionConfiguration.default)
        if configution.needSerializer {
            sessionManager.requestSerializer = AFJSONRequestSerializer()
        }
        sessionManager.requestSerializer.timeoutInterval = TimeInterval(XHNetworkConfigution.shared.timeoutInterval)
//        sessionManager.requestSerializer.setValue("1.2.9", forHTTPHeaderField: "version")
//        sessionManager.requestSerializer.setValue("parent_ios", forHTTPHeaderField: "equipType")
//        sessionManager.requestSerializer.setValue("12345656", forHTTPHeaderField: "equipId")
//        sessionManager.requestSerializer.setValue("zh_CN", forHTTPHeaderField: "Accept-Language")
//        sessionManager.requestSerializer.setValue("cf5ef8cf5c77465091893985805039f3@1261@0", forHTTPHeaderField: "token")
        sessionManager.responseSerializer.acceptableContentTypes = Set(arrayLiteral: "application/json", "text/json", "text/javascript","text/html", "text/plain","application/atom+xml","application/xml","text/xml","application/octet-stream","multipart/mixed")
        return sessionManager
    }
    
    fileprivate func generateRequest(with configution: XHNetworkRequestConfig) -> NSURLRequest? {
        
        guard let method = configution.method else { return nil}
        guard let urlString = configution.urlString else { return nil}
        guard let params = configution.params else { return nil}

        let request:NSMutableURLRequest = self.sessionManager!.requestSerializer.request(withMethod:method, urlString: urlString, parameters: params, error: nil)
        
        return request
    }
    
    fileprivate func startLoadRequest(with request:URLRequest,_ dataTask:URLSessionDataTask?,_ requestConfig:XHNetworkRequestConfig) {
        let requestId:Int = dataTask?.taskIdentifier ?? 0
        let urlRespose:XHURLResponse = XHURLResponse(with: requestConfig, requestId, request)
        urlRespose.startTime = getNowTime()
        self.requestDic?[String(requestId)] = urlRespose
    }
    
    fileprivate func reponseParams(with urlRespose:XHURLResponse, content:Any?, _ responseString:String?, _ error:NSError?,_ responseData:Data?,_ dataTask:URLSessionDataTask?,_ httpResponse:HTTPURLResponse) -> XHURLResponse {
        urlRespose.contentString = responseString
        urlRespose.errorType = urlRespose.responseStatus(with: error as NSError?)
        urlRespose.content = content
        urlRespose.responseData = responseData
        urlRespose.error = error
        urlRespose.task = dataTask
        urlRespose.endTime = self.getNowTime()
        urlRespose.isFormeCache = false
        urlRespose.httpResponse = httpResponse
        return urlRespose
    }
}

extension XHApiProxy {
    func getNowTime() -> String {
        let nowDate = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        let strNowTime = timeFormatter.string(from: nowDate) as String
        return strNowTime
    }
}
