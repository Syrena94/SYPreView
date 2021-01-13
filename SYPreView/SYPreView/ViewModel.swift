//
//  ViewModel.swift
//  SYPreView
//
//  Created by Syrena on 2019/11/4.
//  Copyright © 2019 Syrena. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HandyJSON


class SYApiModel: HandyJSON {
    var reason:String = ""
    var result:SYApiData = SYApiData()
    
    required init(){}
}

class SYApiData: HandyJSON {
    var stat:String = ""
    var data:[SYRecord] = []
    
    required init(){}
}

class SYRecord: HandyJSON {
    var author_name:String = ""
    var thumbnail_pic_s:String = ""
    
    required init(){}
}

class ViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    let dataSource = BehaviorRelay(value: [SYRecord]())
    
    override init() {
        super.init()
        
        let ob = SYNetTool<SYApiModel>.RxmakeRequest(baseUrl: newUrl,parameters: ["key":"6507842fb38c121e250e5143de303de3"])
        ob
            .subscribe(onNext: {[weak self](result) in
                switch result {
                case .success(let data):
                    self?.dataSource.accept(data.result.data)
                case .failure(let msg,_):
                    syLog(msg)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
}



