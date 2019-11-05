//
//  SYNetModel.swift
//  SYSwitf
//
//  Created by Syrena on 2019/9/4.
//  Copyright © 2019 Syrena. All rights reserved.
//

import Foundation
import HandyJSON

/**
 * 字符串类型
 */
class SYStrModel: HandyJSON {
    var status:String = ""
    var msg:String = ""
    var result:String = ""
    
    required init(){}
}
/**
 * 字典类型
 */
class SYDictionaryModel<T:HandyJSON>: HandyJSON {
    var status:String = ""
    var msg:String = ""
    var result:T?
    
    required init(){}
}
/**
 * 数组类型
 */
class SYArrayModel<T:HandyJSON>: HandyJSON {
    var status:String = ""
    var msg:String = ""
    var result:[T] = []
    
    required init(){}
}

class SYNewModel<T:HandyJSON>:HandyJSON{
    var status:String = ""
    var msg:String = ""
    var result:T?
    
    required init(){}
}
