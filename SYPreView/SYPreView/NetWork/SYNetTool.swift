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
        Base_Url = ""
    case .Distribution:
        Base_Url = ""
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
            AF.request(URL, method: method, parameters: dict, encoding: URLEncoding.default, headers: []).responseJSON { (response) in
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

    
    
    
}







