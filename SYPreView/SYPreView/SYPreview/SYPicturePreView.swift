//
//  SYPicturePreView.swift
//  SYSwitf
//
//  Created by Syrena on 2019/10/24.
//  Copyright © 2019 Syrena. All rights reserved.
//

import UIKit


protocol SYPicturePreViewDelegate :class{
    //若要以放大缩小的形式来显示预览视图，必须遵守此协议并返回当前显示图片的原本视图的对象
    func getFromView(currentIndex:Int)->UIView?
}

// MARK: - 关闭控制器
protocol ClosePreViewDelegate :class{
    func preViewDidClose()
}

class SYPicturePreView: UIView {
    
    weak fileprivate var delegate:SYPicturePreViewDelegate?
    weak var closeDelegate:ClosePreViewDelegate?
    fileprivate var fromView:UIView?
    fileprivate var toView:UIView!
    fileprivate var urlImages:[String]!
    fileprivate var picCollectView:UICollectionView!
    fileprivate var isfirst:Bool = true
    fileprivate var currentImgIndex:Int!
    fileprivate var animation:Bool!
    fileprivate var fromViewFrame:CGRect = CGRect.zero
    fileprivate var isScroll:Bool = false

    
    class final func showPreView(image:[String],currentIndex:Int = 0,from:UIView?=nil,to:UIView,isAnimation:Bool = false,delegate:SYPicturePreViewDelegate? = nil){
        _ = SYPicturePreView(image: image, currentIndex: currentIndex, from: from, to: to, isAnimation: isAnimation, preDelegate: delegate)
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(image:[String],currentIndex:Int,from:UIView?,to:UIView,isAnimation:Bool,preDelegate:SYPicturePreViewDelegate?) {
        self.init()
        if image.count == 0 {
            return
        }
        if currentIndex < 0 && currentIndex > image.count-1 {
            return
        }
        backgroundColor = UIColor.clear
        delegate = preDelegate
        fromView = from
        toView = to
        urlImages = image
        currentImgIndex = currentIndex
        animation = isAnimation
        if let view = from {
            fromViewFrame = view.superview!.convert(view.frame, to: toView)
        }
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    fileprivate func setUI(){
        frame = toView.bounds
        toView.addSubview(self)
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0 ,bottom: 0, right: 0)
        layout.itemSize = CGSize.init(width: toView.bounds.width, height: toView.bounds.height)
        
        picCollectView = UICollectionView.init(frame: bounds, collectionViewLayout: layout)
        picCollectView.bounces = false
        picCollectView.backgroundColor = UIColor.clear
        picCollectView.delegate = self
        picCollectView.dataSource = self
        picCollectView.showsVerticalScrollIndicator = false
        picCollectView.showsHorizontalScrollIndicator = false
        picCollectView.register(SYPreviewCollectionViewCell.self, forCellWithReuseIdentifier: "SYPreviewCollectionViewCell")
        picCollectView.isPagingEnabled = true
        addSubview(picCollectView)
        picCollectView.setContentOffset(CGPoint.init(x: bounds.width * CGFloat(currentImgIndex), y: 0), animated: false)
    }
    
    deinit {
        syLog("预览释放")
    }
    
    
}


extension SYPicturePreView:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urlImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SYPreviewCollectionViewCell", for: indexPath) as! SYPreviewCollectionViewCell
        cell.delegate = self
        cell.setImage(img: urlImages[indexPath.item], isAnimation: animation , first: isfirst)
        isfirst = false
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        
        let offset = scrollView.contentOffset
        currentImgIndex = Int((offset.x + frame.size.width/2) / frame.size.width)
        //将起始位置置为(0,0,0,0)
        fromViewFrame = CGRect.zero
        //获得新的起始位置
        if let dele = delegate {
            if let view = dele.getFromView(currentIndex: currentImgIndex){
                fromViewFrame = view.superview!.convert(view.frame, to: toView)
            }
        }
    }

}
extension SYPicturePreView:SYPreviewCollectionViewCellDelegate{
    func getFromFrame() -> CGRect {
        return fromViewFrame
    }
    
    func closeCompletion() {
        self.removeFromSuperview()
        if let del = closeDelegate {
            del.preViewDidClose()
        }
    }
    
    func setCollectScrollenable(isScro: Bool) {
        picCollectView.isScrollEnabled = isScro
    }
    
}
