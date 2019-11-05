//
//  ViewController.swift
//  SYPreView
//
//  Created by Syrena on 2019/11/4.
//  Copyright © 2019 Syrena. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var tabV:UITableView!
    var viewModel:ViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabV = UITableView.init(frame: CGRect.zero, style: .grouped)
        tabV.register(ImgTableViewCell.self, forCellReuseIdentifier: "ImgTableViewCell")
        tabV.frame = view.bounds
        tabV.rowHeight = 100
        view.addSubview(tabV)
        
        viewModel = ViewModel.init()
        
        
        viewModel.dataSource
            .bind(to: (tabV?.rx.items)!){(tab,index,model)->UITableViewCell in
                let cell = tab.dequeueReusableCell(withIdentifier: "ImgTableViewCell") as! ImgTableViewCell
                cell.url = model.thumbnail_pic_s
                return cell
        }
        .disposed(by: disposeBag)
        
        
        tabV.rx.itemSelected
            .subscribe(onNext:{[weak self]indexpath in
                var arr:[String] = []
                self?.viewModel?.dataSource.value.forEach{
                    arr.append($0.thumbnail_pic_s)
                }
                let cell = self?.tabV.cellForRow(at: indexpath) as! ImgTableViewCell
                //预览方法
                //SYPreViewController.show(image: arr)
                SYPreViewController.show(image: arr, currentIndex: indexpath.row, from: cell.img, isAnimation: true, delegate: self)
            })
            .disposed(by: disposeBag)
        
    }
    
    
}

// MARK: - SYPicturePreViewDelegate
extension ViewController:SYPicturePreViewDelegate{
    func getFromView(currentIndex: Int) -> UIView? {
        if let cell = tabV.cellForRow(at: IndexPath.init(row: currentIndex, section: 0)) {
            let imgcell = cell as! ImgTableViewCell
            return imgcell.img
        }
        return nil
    }
}

