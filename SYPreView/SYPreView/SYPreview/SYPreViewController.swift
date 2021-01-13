//
//  SYPreViewController.swift
//  SYSwitf
//
//  Created by Syrena on 2019/10/29.
//  Copyright © 2019 Syrena. All rights reserved.
//

import UIKit


/**
 * 可以将父类改为自己的基类，配合项目使用。
 */
class SYPreViewController: UIViewController {
    
    var preView:SYPicturePreView!

    
    /**
     * SYPreview
     * image:网络图片，如果为空则什么都不会发生
     * currentIndex:预览显示的是第几张图
     * from:起始位置的ImageView,若想以动画的形式打开预览则必传而且必须准守协议
     * isAnimation:开始结束是否以动画形式进行
     * SYPicturePreViewDelegate:若想以动画的形式打开预览则必须准守协议
     */
    class final func show(image:[String],currentIndex:Int = 0,from:UIView?=nil,isAnimation:Bool = false,delegate:SYPicturePreViewDelegate? = nil){
        if image.count == 0 {
            return
        }
        if currentIndex < 0 && currentIndex > image.count-1 {
            return
        }
        
        let vc = SYPreViewController()
        vc.view.backgroundColor = UIColor.clear
        //唤醒
        DispatchQueue.main.async {
            vc.preView = SYPicturePreView(image: image, currentIndex: currentIndex, from: from, to: vc.view, isAnimation: isAnimation, preDelegate: delegate)
            vc.preView.closeDelegate = vc
            
            let nav = UINavigationController.init(rootViewController: vc)
            nav.modalPresentationStyle = .overCurrentContext
            
            syCurrentViewController.present(nav, animated: false, completion: nil)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //设置导航栏透明
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //这段别删
        let a = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        a.backgroundColor = UIColor.clear
        view.addSubview(a)
        
        //demo展示用,不要要将其注释
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "跳转", style: .plain, target: self, action: #selector(pushVc))
    }
    
    @objc
    fileprivate func pushVc(){
        let vc = NextViewController()
        vc.title = "next"
        navigationController?.pushViewController(vc)
    }
    
    
    deinit {
        syLog("预览控制器释放")
    }
}

extension SYPreViewController:ClosePreViewDelegate{
    func preViewDidClose() {
        self.dismiss(animated: false, completion: nil)
    }
}
