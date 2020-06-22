//
//  WKCVideoHorizontalPageControl.swift
//  SwfitTest
//
//  Created by wkcloveYang on 2020/6/22.
//  Copyright © 2020 wkcloveYang. All rights reserved.
//

import UIKit

@objc public protocol WKCVideoHorizontalPageControlDelegate: NSObjectProtocol {
    
    /// 个数
    @objc func videoHorizontalPageControlNumberOfItems() -> Int
    
    /// 当前item
    @objc func videoHorizontalPageControlItemForCurrent(index: Int) -> UIView
    
    /// other item
    @objc func videoHorizontalPageControlItemForOthers(index: Int) -> UIView
    
    /// 当前item size
    @objc func videoHorizontalPageControlSizeForCurrent() -> CGSize
    
    /// other item size
    @objc func videoHorizontalPageControlSizeForOthers() -> CGSize
    
    /// 间距
    @objc optional func videoHorizontalPageControlSpacing() -> CGFloat
    
    /// 四周嵌入量
    @objc optional func videoHorizontalPageControlInserts() -> UIEdgeInsets
    
    /// 点击了某项
    /// - Parameter index: index
    @objc optional func videoHorizontalPageControlDidSelectItem(index: Int)
}

open class WKCVideoHorizontalPageControl: UIView {

    open var delegate: WKCVideoHorizontalPageControlDelegate? {
        willSet {
            if let value = newValue {
                
                numberOfItems = value.videoHorizontalPageControlNumberOfItems()
                
                currentItemSize = value.videoHorizontalPageControlSizeForCurrent()
                
                othersItemSize = value.videoHorizontalPageControlSizeForOthers()
                
                if value.responds(to: #selector(WKCVideoHorizontalPageControlDelegate.videoHorizontalPageControlSpacing)) {
                    spacing = value.videoHorizontalPageControlSpacing?()
                }
                
                if value.responds(to: #selector(WKCVideoHorizontalPageControlDelegate.videoHorizontalPageControlInserts)) {
                    inserts = value.videoHorizontalPageControlInserts?()
                }
            }
        }
    }
    
    open var currentIndex: Int = 0 {
        willSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    fileprivate var numberOfItems: Int! = 0
    fileprivate var currentItemSize: CGSize! = CGSize.zero
    fileprivate var othersItemSize: CGSize! = CGSize.zero
    fileprivate var spacing: CGFloat! = 0
    fileprivate var inserts: UIEdgeInsets! = UIEdgeInsets.zero
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.backgroundView = nil
        view.backgroundColor = nil
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewCell.self))
        return view
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(collectionView)
        collectionView.frame = self.bounds
    }
}


// MARK: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource
extension WKCVideoHorizontalPageControl: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return inserts
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.row == currentIndex ? currentItemSize : othersItemSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewCell.self), for: indexPath)
        cell.contentView.layer.masksToBounds = true
        
        guard let de = delegate else { return cell }
        
        for sub in cell.contentView.subviews {
            sub.removeFromSuperview()
        }
        
        if indexPath.row == currentIndex {
            cell.contentView.addSubview(de.videoHorizontalPageControlItemForCurrent(index: indexPath.row))
        } else {
            cell.contentView.addSubview(de.videoHorizontalPageControlItemForOthers(index: indexPath.row))
        }
        return cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let de = delegate, de.responds(to: #selector(WKCVideoHorizontalPageControlDelegate.videoHorizontalPageControlDidSelectItem(index:))) {
            de.videoHorizontalPageControlDidSelectItem?(index: indexPath.row)
        }
    }
}
