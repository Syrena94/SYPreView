//
//  SYPreviewCollectionViewCell.swift
//  SYSwitf
//
//  Created by Syrena on 2019/10/24.
//  Copyright © 2019 Syrena. All rights reserved.
//

import UIKit
import Kingfisher
import SwifterSwift


//用于获得该图片在原本视图上的位置  SYPreviewCollectionViewCell->SYPicturePreView<-toView
protocol SYPreviewCollectionViewCellDelegate:class {
    //获得起始位置
    func getFromFrame()->CGRect
    //关闭结束时调用
    func closeCompletion()
    //关闭collectView移动
    func setCollectScrollenable(isScro:Bool)
}

class SYPreviewCollectionViewCell: UICollectionViewCell {
    
    weak var delegate:SYPreviewCollectionViewCellDelegate!
    fileprivate var imgUrl:String!
    fileprivate var animation:Bool = false
    fileprivate var scroContainer:UIScrollView!
    fileprivate var imgView:UIImageView!
    fileprivate var isfirst:Bool!
    
    fileprivate var panGesture:UIPanGestureRecognizer!
    fileprivate var singleTapGesture:UITapGestureRecognizer!
    fileprivate var doubleTapGesture:UITapGestureRecognizer!
    
    //移动手势是否激活
    fileprivate var isPanActivate:Bool = false
    //是否是长图
    fileprivate var isLongPic:Bool = false
    //拖拽速度
    fileprivate var panSpeed:CGFloat = 0
    
    
    
    
    
    /**
     * 设置图片
     * img:图片地址,startFrame:启动位置(isAnimation为false时不使用),isAnimation:是否动画显示
     */
    func setImage(img:String,isAnimation:Bool = false,first:Bool){
        imgUrl = img
        animation = isAnimation
        isfirst = first
        imgView.kf.setImage(with: URL.init(string: imgUrl), placeholder: UIImage.init(color: UIColor.white, size: CGSize(width: bounds.width, height: 300))) { [weak self](result) in
            //图片加载完成时重新去计算大小
            self?.reSetImgSize()
        }
        reSetImgSize()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUI(){
        scroContainer = UIScrollView.init(frame: bounds)
        scroContainer.maximumZoomScale = 1.8
        scroContainer.minimumZoomScale = 1.0
        scroContainer.isMultipleTouchEnabled = true//开启多点触碰
        scroContainer.showsVerticalScrollIndicator = false
        scroContainer.showsHorizontalScrollIndicator = false
        scroContainer.scrollsToTop = false//关闭触碰状态栏自动滚动到顶部
        scroContainer.autoresizingMask = [.flexibleWidth,.flexibleHeight]//子视图的宽度和高度随父视图的变化而改变
        scroContainer.backgroundColor = UIColor.clear
        scroContainer.delegate = self
        
        contentView.addSubview(scroContainer)
        imgView = UIImageView.init()
        imgView.backgroundColor = UIColor.clear
        
        
        scroContainer.addSubview(imgView)
        if #available(iOS 11.0, *) {
            scroContainer.contentInsetAdjustmentBehavior = .never
        }
        
        //添加单击 双击 滑动
        singleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGesture(tap:)))
        doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(doubletapGesture(tap:)))
        doubleTapGesture.numberOfTapsRequired = 2
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureAction(pan:)))
        panGesture.delegate = self
        
        //当单击手势发生时，不会立刻触发，会等到双击手势失败之后才触发。
        singleTapGesture.require(toFail: doubleTapGesture)
        
        scroContainer.addGestureRecognizers([singleTapGesture,doubleTapGesture,panGesture])
    }
    
    // MARK: - 拖动
    @objc
    func panGestureAction(pan:UIPanGestureRecognizer){
        
        switch pan.state {
        case .began:
            syLog("pan手势触发")
        case .changed:
            //syLog("拖动手势拖动中。。。。。")
            let offset = pan.translation(in: pan.view)
            if (offset.y > 0 && scroContainer.contentOffset.y <= 0) || isPanActivate == true {
                scroContainer.isScrollEnabled = false
                let velocity = pan.velocity(in: pan.view)
                panSpeed = velocity.y
                isPanActivate = true
                
                //移动滚动容器的位置，根据移动的距离缩放大小
                let centerP = scroContainer.center
                scroContainer.center = CGPoint.init(x: centerP.x+offset.x, y: centerP.y+offset.y)
                //比例计算
                let scale:CGFloat = 1.0 - (scroContainer.center.y - center.y)/bounds.height
                scroContainer.transform = CGAffineTransform.init(scaleX: min(scale, 1), y: min(scale, 1))
                
                backgroundColor = UIColor.init(white: 0, alpha: min(scale, 1))
            }
            //复位
            pan.setTranslation(CGPoint.zero, in: pan.view)
        case .ended:
            isPanActivate = false
            delegate.setCollectScrollenable(isScro: true)
            scroContainer.isScrollEnabled = true
            
            if panSpeed > 1000 {
                tapGesture(tap: singleTapGesture)
            }else{
                UIView.animate(withDuration: 0.3) {[weak self] in
                    self?.backgroundColor = UIColor.black
                    self?.scroContainer.transform = CGAffineTransform.identity
                    
                    if let rect = self?.bounds {
                        self?.scroContainer.frame = CGRect.init(x: 0, y: 0, width: rect.width, height: rect.height)
                    }
                    
                }
            }
            
        default:
            syLog("其他状态")
        }
    }
    
    // MARK: - 单击
    @objc
    func tapGesture(tap:UITapGestureRecognizer){
        if animation == true && !delegate.getFromFrame().equalTo(CGRect.zero) {
            let offset = scroContainer.contentOffset
            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                if let closeframe = self?.delegate.getFromFrame() {
                    //这里几行代码主要是解决在放大或者(或者都有)有偏移量时,回到初始位置时一些位置不准确的问题。
                    self?.scroContainer.setContentOffset(CGPoint.init(x: offset.x, y: 0), animated: false)
                    self?.scroContainer.setZoomScale(1, animated: false)
                    self?.scroContainer.transform = CGAffineTransform.identity
                    if let rect = self?.bounds {
                        self?.scroContainer.frame = CGRect.init(x: 0, y: 0, width: rect.width, height: rect.height)
                    }
                    
                    self?.imgView.frame = closeframe
                    self?.backgroundColor = UIColor.clear
                }
            }) { [weak self]_ in
                self?.delegate.closeCompletion()
            }
        }else{
            UIView.animate(withDuration: 0.2, animations: {[weak self] in
                self?.backgroundColor = UIColor.clear
                self?.imgView.alpha = 0;
            }) { [weak self]_ in
                self?.delegate.closeCompletion()
            }
        }
    }
    // MARK: - 双击
    @objc
    func doubletapGesture(tap:UITapGestureRecognizer){
        if scroContainer.zoomScale > 1 {
            scroContainer.setZoomScale(1, animated: true)
        }else{
            //双击位置
            let point = tap.location(in: imgView)
            //放大区域大小
            let zoomSize = CGSize.init(width: scroContainer.size.width/scroContainer.maximumZoomScale, height: scroContainer.size.height/scroContainer.maximumZoomScale)
            let zoomRect = CGRect(x: point.x-zoomSize.width/2, y: point.y-zoomSize.height/2, width: zoomSize.width, height: zoomSize.height);
            scroContainer.zoom(to: zoomRect, animated: true)
        }
    }
    
    
    fileprivate func reSetImgSize(){
        //设定一个初始大小
        var containerframe = CGRect(x: 0, y: 0, width: width, height: 0)
        
        //let imgSize = getImgSize(url: imgUrl)
        if let img = imgView.image {
            let imgSize = img.size
            if imgSize.height/imgSize.width > frame.size.height/frame.size.width {
                //当图片高宽比大于显示区域的宽高比时，计算出高度，此时是一个长图,且图片显示的原点是(0,0)
                containerframe.size.height = imgSize.height / (imgSize.width/frame.size.width)
                isLongPic = true
            }else{
                //当图片高宽比小于显示区域的宽高比时，图片的中心点在显示区域的中心
                containerframe.size.height = imgSize.height / (imgSize.width/frame.size.width)//
                containerframe.origin.y = frame.size.height/2 - containerframe.size.height/2
                isLongPic = false
            }
        }else{
            containerframe.size.height = 300
            containerframe.origin.y = frame.size.height/2 - 150
        }
        //设置容器大小
        scroContainer.contentSize = containerframe.size
        //回到初始位置
        scroContainer.scrollRectToVisible(frame, animated: false)
        scroContainer.setZoomScale(1, animated: false)
        
        
        //当1. 是否动画为true 2. 起始位置不为原点size 3. 第一个显示的图片 都满足时 才已放大的形式打开
        if animation == true && !delegate.getFromFrame().equalTo(CGRect.zero) && isfirst {
            isfirst = false
            imgView.frame = delegate.getFromFrame()
            UIView.animate(withDuration: 0.2) {[weak self] in
                self?.imgView.frame = containerframe
                self?.backgroundColor = UIColor.black
            }
        }else{
            backgroundColor = UIColor.black
            imgView.frame = containerframe
        }
        
    }
}


extension SYPreviewCollectionViewCell:UIScrollViewDelegate{
    //选择放大的视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    //当放大结束时，应当把图片的中心点放在容器的中间，
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //当容器的frame宽度大于contensize宽度时，要根据多出来的一部分宽的的一般进行偏移
        let contentX = scrollView.frame.width>scrollView.contentSize.width ? (scrollView.frame.width-scrollView.contentSize.width)*0.5:0
        //同理高度
        let contentY = scrollView.frame.height>scrollView.contentSize.height ? (scrollView.frame.height-scrollView.contentSize.height)*0.5:0
        
        imgView.center = CGPoint.init(x: scroContainer.contentSize.width*0.5+contentX, y: scroContainer.contentSize.height*0.5+contentY)
    }
    
    
}

extension SYPreviewCollectionViewCell:UIGestureRecognizerDelegate{
    
    
    //打开手势共享  手势的触发事件会往下传递
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            let pan = gestureRecognizer as! UIPanGestureRecognizer
            let velocity = pan.velocity(in: pan.view)
            
            //水平速度大于垂直速度是左右滑动，关闭拖拽手势，但是事件会往下传递
            if abs(velocity.x) > abs(velocity.y) {
                delegate.setCollectScrollenable(isScro: true)
                return false
            }
        }
        delegate.setCollectScrollenable(isScro: false)
        return true
    }
    
    
}
