//
//  SYNetTool.swift
//  SYSwitf
//
//  Created by Syrena on 2019/9/4.
//  Copyright © 2019 Syrena. All rights reserved.
//


import Alamofire
import SwiftyJSON
import HandyJSON
import RxSwift



enum SYNetEnvironment{
    case Development
    case Test
    case Distribution
}
enum NetResult<data>{
    case success(data)
    case failure(String,data)
    case neterror(Error)
}

enum SYNetError:Error{
    case jsonerror //根据项目需求自定义error
}

var Base_Url = ""
// MARK: - 判断网络环境
private func getCurrentNet(network : SYNetEnvironment = .Test){
    switch network {
    case .Test:
        Base_Url = ""
    case .Development:
        Base_Url = "http://xjd.51shujin.com/"
    case .Distribution:
        Base_Url = "http://xjd.51shujin.com/"
    }
}


class SYNetTool<T:HandyJSON>{
    
    typealias ResultReturn = (NetResult<T>)->()
    
    
    static func RxmakeRequest(baseUrl : String,method:HTTPMethod = .get,parameters : [String:Any] = [:]) -> Observable<NetResult<T>>{
        return Observable<NetResult<T>>.create({ (ob) -> Disposable in
            //判断项目接口的环境
            syLog("发起了网络请求")
            getCurrentNet()
            let URL = Base_Url + baseUrl
            let dict = parameters
            Alamofire.request(URL, method: method, parameters: dict, encoding: URLEncoding.default, headers: ["Authorization":"APPCODE 9524773a7ff64fbc816a0c011121dd92"]).responseJSON { (response) in
                switch response.result{
                case .success(let data):
                    let json = JSON(data)
                    if let obj = T.deserialize(from: json.dictionaryObject){
                        if json["result"]["stat"].intValue == 1{
                            ob.onNext(.success(obj))
                        }else{
                            ob.onNext(.failure(json["msg"].stringValue, obj))
                        }
                    }else{
                        ob.onNext(.neterror(SYNetError.jsonerror))
                    }
                case .failure(let error):
                    ob.onNext(.neterror(error))
                }
            }
            return Disposables.create()
        })
    }
    
    
    /**
     * 网络请求(传入泛型)
     * url 地址(必传)
     * method 请求方式(默认.get)
     * parameters 参数(默认空字典)
     */
    static func makeRequest(url : String,method:HTTPMethod = .get,parameters : [String:Any] = [:], resultHandler: @escaping ResultReturn){
        //判断项目接口的环境
        getCurrentNet()
        let URL = Base_Url + url
        let dict = parameters//做参数区分(很有必要)
        Alamofire.request(URL, method: method, parameters: dict, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result{
            case .success(let data):
                //利用SwiftJson转数据
                let json = JSON(data)
                //用HandyJsond将[String:Any]的数据类型转为模型
                if let obj = T.deserialize(from: json.dictionaryObject){
                    if json["status"].intValue == 1{
                        //后定定的规则是当status为1时，数据请求成功，这个规则不同项目不定，视情况判断
                        resultHandler(.success(obj))
                    }else{
                        //返回错误信息
                        resultHandler(.failure(json["msg"].stringValue, obj))
                    }
                }else{
                    //当转模型不成功时做处理
                    resultHandler(.neterror(SYNetError.jsonerror))
                }
            case .failure(let error):
                //接口请求失败做处理
                resultHandler(.neterror(error))
            }
        }
    }

    
    /**
     * 图片上传
     */
    static func upDataIamgeRequest(baseUrl : String,parameters : [String : String],imageArr : [UIImage],resultHandler: @escaping (NetResult<T>)->()){
        
        getCurrentNet()
        
        let URL = Base_Url + baseUrl
        
        if(imageArr.count == 0){
            
            return;
        }
        
        let image = imageArr.first;
        let imageData = image?.jpegData(compressionQuality: 0.5)
        
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
                //for (key, value) in parameters {
                    //参数的上传
                    //multipartFormData.append((value.data(using: String.Encoding.utf8)!), withName: key)
                //}
            
            multipartFormData.append(imageData!, withName: "file", fileName: "headImg.png", mimeType: "image/jpeg")
            //如果需要上传多个文件,就多添加几个
            //multipartFormData.append(imageData, withName: "file", fileName: "123456.jpg", mimeType: "image/jpeg")
            //......
            
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: URL, method: .post, headers: nil) { (encodingResult) in
            
            // print(encodingResult)
            switch encodingResult {
            case .success(let upload, _, _):
                //连接服务器成功后，对json的处理
                upload.responseJSON { response in
                    //解包
                    guard let jsonvalue = response.result.value else {
                        return
                    }
                    let json = JSON(jsonvalue)
                    //  print(json)
                    // 请求成功 但是服务返回的报错信息
                    if let obj = T.deserialize(from: json.dictionaryObject){
                        if json["status"].intValue == 1{
                            resultHandler(.success(obj))
                        }else{
                            resultHandler(.failure(json["msg"].stringValue, obj))
                        }
                    }else{
                        //errorMsgHandler
                    }
                }
                /*
                 //获取上传进度
                 upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                 print("图片上传进度: \(progress.fractionCompleted)")
                 }
                 */
                
            case .failure(let encodingError):
                resultHandler(.neterror(encodingError))
            }
        }
    }
    
}







