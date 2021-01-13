//
//  SYPreViewCommon.swift
//  SYPreView
//
//  Created by Syrena on 2019/11/4.
//  Copyright © 2019 Syrena. All rights reserved.
//

import Foundation
import UIKit

var syCurrentViewController:UIViewController{
    let rootViewController = UIApplication.shared.keyWindow?.rootViewController
    return currentViewControllerFrom(vc: rootViewController!)
}
var syCurrentNavigationViewController:UINavigationController{
    let vc:UIViewController = syCurrentViewController
    return vc.navigationController!
}


// MARK: - 递归获得当前控制器
/**
 * 递归获得当前控制器
 */
func currentViewControllerFrom(vc:UIViewController)->UIViewController{
    if vc.isKind(of: UINavigationController.self) {
        let navigationController = vc as! UINavigationController
        return currentViewControllerFrom(vc: navigationController.viewControllers.last!)
    }else if vc.isKind(of: UITabBarController.self){
        let tabBarController = vc as! UITabBarController
        return currentViewControllerFrom(vc: tabBarController.selectedViewController!)
    }else if vc.presentedViewController != nil{
        return currentViewControllerFrom(vc: vc.presentedViewController!)
    }else{
        return vc
    }
}


// MARK:- 自定义打印方法
func syLog<T>(_ message : T..., file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("类名:\(fileName)-第(\(lineNum))行-打印值:\n\(message)")
    #endif
}
