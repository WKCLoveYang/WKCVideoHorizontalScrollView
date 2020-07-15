//
//  WKCVideoHorizontalScrollView.swift
//  SwfitTest
//
//  Created by wkcloveYang on 2020/6/19.
//  Copyright © 2020 wkcloveYang. All rights reserved.
//

import UIKit
import iCarousel

@objc public protocol WKCVideoHorizontalScrollViewDelegate: NSObjectProtocol {
    
    /// 数据
    @objc func videoHorizontalScrollViewDataSource() -> [WKCVideoHorizontalScrollBaseModel]
    
    /// itemView
    @objc func videoHorizontalScrollViewPageView() -> WKCVideoHorizontalScrollPageView
    
    /// index改变
    @objc optional func videoHorizontalScrollViewCurrentItemIndexChanged(index: Int)
    
    /// 点击了某项
    @objc optional func videoHorizontalScrollViewDidSelectItem(index: Int)
}

public class WKCVideoHorizontalScrollView: UIView {
    
    /// 代理
    public weak var delegate: WKCVideoHorizontalScrollViewDelegate?
    
    /// 基础scrollView
    public lazy var scrollView: iCarousel = {
        let view = iCarousel()
        view.isPagingEnabled = true
        view.scrollSpeed = 1.5
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    /// 当前坐标
    public var currentIndex: Int = 0 {
        willSet {
            DispatchQueue.main.async {
                self.scrollView.currentItemIndex = newValue
            }
        }
    }
    
    fileprivate var imageNotification: String = WKCImagePlayEndNotification
    fileprivate var videoNotification: String = kWKCVideoPlayEndNotification
    fileprivate var dataSource: [WKCVideoHorizontalScrollBaseModel]?
    fileprivate var itemSize: CGSize?
    fileprivate var itemSpacing: CGFloat?
    
    fileprivate var pageViewPool: [Int: WKCVideoHorizontalScrollPageView] = [Int: WKCVideoHorizontalScrollPageView]()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        handleIdentifys()
        addSubview(scrollView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onApplicationBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onApplicationEnterBack), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidPlayToEnd(notification:)), name: NSNotification.Name(imageNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidPlayToEnd(notification:)), name: NSNotification.Name(videoNotification), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = self.bounds
        reloadData()
    }
    
    deinit {
        debugPrint("====== WKCVideoHorizontalScrollView is dealloc!!! ======")
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: 接口
extension WKCVideoHorizontalScrollView {
    
    /// 刷新数据
    public func reloadData() {
        guard let de = delegate else { return }
        // 去接受整体数据
        if de.responds(to: #selector(WKCVideoHorizontalScrollViewDelegate.videoHorizontalScrollViewDataSource)) {
            dataSource = de.videoHorizontalScrollViewDataSource()
        }

        inner_reloadData()
    }
    
}


// MARK: InnerMethod
extension WKCVideoHorizontalScrollView {
    
    fileprivate func handleIdentifys() {
        let imageValue = identifyRandomCounts()
        imageNotification = String.random(imageValue)
        let videoValue = identifyRandomCounts()
        videoNotification = String.random(videoValue)
    }
    
    fileprivate func identifyRandomCounts() -> Int {
        return Int(32 + arc4random() % 36)
    }
    
    fileprivate func inner_reloadData() {
        DispatchQueue.main.async {
            self.scrollView.reloadData()
            self.refreshContent()
        }
    }
    
    fileprivate func refreshContent() {
        DispatchQueue.main.async {
            self.pageViewPool.forEach { [weak self] (key, value) in
                if let weakself = self {
                    if key == weakself.scrollView.currentItemIndex {
                        value.restartPlay()
                    } else {
                        value.stopPlay()
                    }
                }
            }
        }
    }
    
    fileprivate func refreshActive() {
        DispatchQueue.main.async {
            self.pageViewPool.forEach { [weak self] (key, value) in
                if let weakself = self {
                    if key == weakself.scrollView.currentItemIndex {
                        value.startPlay()
                    } else {
                        value.stopPlay()
                    }
                }
            }
        }
    }
    
    fileprivate func refreshDraggingContent() {
        let itemView: WKCVideoHorizontalScrollPageView = pageViewPool[scrollView.currentItemIndex]!
        if !itemView.isPlaying {
            itemView.restartPlay()
        }
    }
    
    fileprivate func stopAll() {
        DispatchQueue.main.async {
            self.pageViewPool.forEach { (_, value) in
                value.stopPlay()
            }
        }
    }
    
    @objc fileprivate func onDidPlayToEnd(notification: Notification) {
        let pageView: WKCVideoHorizontalScrollPageView? = pageViewPool[scrollView.currentItemIndex]
        if let _ = pageView {
            scrollView.scrollToItem(at: scrollView.currentItemIndex + 1, animated: true)
        }
    }
    
    @objc fileprivate func onApplicationBecomeActive() {
        refreshActive()
    }
    
    @objc fileprivate func onApplicationEnterBack() {
        stopAll()
    }
}


// MARK: iCarouselDelegate, iCarouselDataSource
extension WKCVideoHorizontalScrollView: iCarouselDelegate, iCarouselDataSource {
    
    public func numberOfItems(in carousel: iCarousel) -> Int {
        guard let data = dataSource else { return 0 }
        return data.count
    }
    
    public func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        guard let data = dataSource else { return UIView() }
        
        var pageView: WKCVideoHorizontalScrollPageView? = pageViewPool[index]
        if pageView == nil {
            if let de = delegate, de.responds(to: #selector(WKCVideoHorizontalScrollViewDelegate.videoHorizontalScrollViewPageView)) {
                pageView = de.videoHorizontalScrollViewPageView()
                pageView?.imageNotification = imageNotification
                pageView?.videoNotification = videoNotification
                pageViewPool[index] = pageView
            }
        }
        
        pageView!.model = data[index]
        return pageView!
    }
    
    public func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        refreshContent()
        if let de = delegate, de.responds(to: #selector(WKCVideoHorizontalScrollViewDelegate.videoHorizontalScrollViewCurrentItemIndexChanged(index:))) {
            de.videoHorizontalScrollViewCurrentItemIndexChanged?(index: carousel.currentItemIndex)
        }
    }
    
    public func carouselDidEndDragging(_ carousel: iCarousel, willDecelerate decelerate: Bool) {
        refreshDraggingContent()
    }
    
    public func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .wrap {
            return 1.0
        } else {
            return value
        }
    }
    
    public func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        if let de = delegate, de.responds(to: #selector(WKCVideoHorizontalScrollViewDelegate.videoHorizontalScrollViewDidSelectItem(index:))) {
            de.videoHorizontalScrollViewDidSelectItem?(index: index)
        }
    }
}
