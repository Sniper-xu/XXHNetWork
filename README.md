# 封装缓存、日志输出、参数，返回数据拦截控制
 
### 1.数据缓存 

XXHNetwork提供了独立的缓存模块（XHNetworkCacheManager）该模块底层运用的是YYCache,因为YYCache LRU算法比较符合我们现实的使用场景，当然我们系统提供的NSCache也是ok的，看个人喜好吧。缓存模块提供下面功能
- 支持最大缓存数量
- 缓存版本控制、app版本检测
- 根据请求shouldAllIgnoreCache判断是否需要缓存
- 缓存的有效时长
- 内存、磁盘两中存储方式
- 缓存数据增、删、改、查

### 2.日志输出

日志输出由独立的模块XHNetworkLogManager控制，里面提供各种情况（成功、失败）下日志输出接口，只需要调用初始化方法传入相应数据即可！
- func appendURL：用于打印请求head、body信息
- func logDebugInfo：用于打印请求返回数据信息
当然你也可以根据自己的需求在这个模块增加日志收集接口等等个人业务相关等需求

### 3.底层接口分离

- XXHNetwork跟底层AF交互的只有XHApiProxy一个类，同时只有一个方法（func callNetwork）这一个方法跟AF交互，其他所有不同方式请求处理都是通过调用该方法，也就是以后如果想替换AFNetworking那么只需要更换这一个方法即可替换非常方便！
- 底层方法callNetwork还增加了一些基本的code处理，对于一些明显的错误，例如token失效等，这里直接放在最底层进行处理这样只需要处理一次即可。
- XHApiProxy提供供外界调用基本请求接口，同时还提供了请求控制接口，可以实现部分或者全部取消请求。

### 4.上层接口

 - block形式:XHNetworkBlockManager，只要实现相应的成功、失败回调即可，相关的错误类型查看XHNetworkErrorType
- delegate形式：XHNetworkDelegateManager，这个可用于参数控制，数据返回检测，只要实现相应的代理即可实现相应功能,详细看注释。
- XHNetworkConfigution：网络配置，网络基本配置在这里修改
- XHNetworkRequestConfig：请求配置，你可以根据业务需求初始化具体的配置，你也可以不用管使用默认的请求配置。
- XHURLResponse：返回数据对象，不管成功还是失败都会返回该对象，该对象包含了所有需要信息，AN返回的基本数据responseObject为（content），error：为错误信息。其他信息请查看注释。

### 5.使用

### - block使用：
```
XHNetworkBlockManager.shared.request(Method: XHNetworkRequestType.get, APIString: "", Parameters: params, SuccessBlock: { (successResponse) in
            print("--------------方式一（block形式）请求数据成功----------")
            self.testManager.loadData()
        }) { (failureResponse) in
            print("--------------方式一请求数据失败----------")
        }
```
### - delegate使用：
1.创建一个继承XHNetworkDelegateManager的业务请求中间管理类：XHNetworkTestManager。这个类专门来实现一些公用的业务代理XHAPIManagerValidator、XHAPIManager等当然你也可以不用，那么你的代理实现就必须在具体的业务中，这样会增加业务代码量，所以不推荐。
2.调用
统一加载方法： loadData
加载更多方法：loadMoreData
```
//代理方式调用
self.testManager.loadData()
```
3.在具体业务中创建一个中间管理类的对象testManager
然后在业务接着完成剩余代理的实现
```
lazy var testManager:XHNetworkTestManager = {
        
        let testManager = XHNetworkTestManager()
        testManager.callBackDelagate = self
        testManager.paramSourceDelegate = self
        return testManager
    }()
```
```
//参数代理，在这里传送请求参数
    func configeApiParams(Manager manager: XHNetworkDelegateManager) -> [String : Any]? {
        
        let dic = [String : Any]()
        return dic
    }
    //返回数据代理
    func requesApiSuccess(Manager manager: XHNetworkDelegateManager) {
        print("--------------方式二（delegate形式）请求数据成功----------")
    }
    
    func requesApiFailure(Manager manager: XHNetworkDelegateManager) {
        print("--------------方式二请求数据失败----------")
    }
```
