//
//  ViewController.swift
//  SwiftCommon
//
//  Created by wkcloveYang on 2020/6/22.
//  Copyright © 2020 wkcloveYang. All rights reserved.
//

import UIKit


class ViewController: UIViewController, WKCVideoHorizontalScrollViewDelegate, WKCVideoHorizontalPageControlDelegate {
    
    private lazy var scrollView: WKCVideoHorizontalScrollView = {
        let view = WKCVideoHorizontalScrollView(frame: CGRect(x: 0, y: 100, width: self.view.bounds.width, height: 200))
        view.delegate = self
        return view
    }()
    
    private lazy var pageControl: WKCVideoHorizontalPageControl = {
        let view = WKCVideoHorizontalPageControl(frame: CGRect(x: 0, y: 320, width: self.view.bounds.width, height: 20))
        view.delegate = self
        return view
    }()
    
    private lazy var dataSource: [WKCVideoHorizontalScrollBaseModel] = {
        let model1 = WKCVideoHorizontalScrollBaseModel()
        model1.image = "1.jpg"
        model1.imageDuration = 2
        
        let model2 = WKCVideoHorizontalScrollBaseModel()
        model2.image = "3.jpg"
        model2.imageDuration = 5
        
        let model3 = WKCVideoHorizontalScrollBaseModel()
        model3.video = Bundle.main.path(forResource: "launch", ofType: "mov")
        
        return [model1, model2, model3]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        view.addSubview(pageControl)
 
        scrollView.reloadData()
    }

    // MARK: WKCVideoHorizontalScrollViewDelegate
    func videoHorizontalScrollViewDataSource() -> [WKCVideoHorizontalScrollBaseModel] {
        return dataSource
    }
    
    func videoHorizontalScrollViewPageView() -> WKCVideoHorizontalScrollPageView {
        return WKCVideoHorizontalScrollPageView(itemSize: CGSize(width: 300, height: 200), magin: 15)
    }
    
    func videoHorizontalScrollViewCurrentItemIndexChanged(index: Int) {
        pageControl.currentIndex = index
    }
    
    
    // MARK: WKCVideoHorizontalPageControlDelegate
    func videoHorizontalPageControlNumberOfItems() -> Int {
        return dataSource.count
    }
    
    func videoHorizontalPageControlSpacing() -> CGFloat {
        8
    }
    
    func videoHorizontalPageControlSizeForCurrent() -> CGSize {
        return CGSize(width: 20, height: 20)
    }
    
    func videoHorizontalPageControlSizeForOthers() -> CGSize {
        return CGSize(width: 15, height: 15)
    }
    
    func videoHorizontalPageControlInserts() -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func videoHorizontalPageControlItemForOthers(index: Int) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 15, height: 15)))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }

    func videoHorizontalPageControlItemForCurrent(index: Int) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
        view.backgroundColor = UIColor.black
        view.layer.cornerRadius = 4
        return view
    }
}

