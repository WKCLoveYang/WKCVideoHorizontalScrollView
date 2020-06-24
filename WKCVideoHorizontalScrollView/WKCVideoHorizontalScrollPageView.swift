//
//  WKCVideoHorizontalScrollPageView.swift
//  SwfitTest
//
//  Created by wkcloveYang on 2020/6/19.
//  Copyright © 2020 wkcloveYang. All rights reserved.
//

import UIKit

public let WKCImagePlayEndNotification: String = "wkc.image.play.end"

open class WKCVideoHorizontalScrollPageView: UIView {
    
    open var model: WKCVideoHorizontalScrollBaseModel? {
        willSet {
            guard let value = newValue else { return }
            if value.isVideo {
                videoView.url = URL(fileURLWithPath: value.video!)
                videoView.isHidden = false
                imageView.isHidden = true
            } else {
                imageView.isHidden = false
                videoView.isHidden = true
                imageView.image = UIImage(named: value.image!)
            }
        }
    }
    
    open var isPlaying: Bool {
        return videoView.isPlaying
    }
    
    open lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(x: magin / 2.0, y: 0, width: itemSize.width - magin, height: itemSize.height))
        view.layer.masksToBounds = true
        return view
    }()
    
    open lazy var imageView: UIImageView = {
        let view = UIImageView(frame: contentView.bounds)
        view.contentMode = .scaleAspectFill
        view.isHidden = true
        return view
    }()
    
    open lazy var videoView: WKCVideoHorizontalScrollVideoView = {
        let view = WKCVideoHorizontalScrollVideoView(url: nil, size: contentView.bounds.size)
        view.frame = contentView.bounds
        view.isHidden = true
        return view
    }()
    
    fileprivate var itemSize: CGSize!
    fileprivate var magin: CGFloat!

    public convenience init(itemSize: CGSize, magin: CGFloat) {
        self.init()
        
        self.itemSize = itemSize
        self.magin = magin
        self.frame = CGRect(origin: .zero, size: itemSize)
        
        setupSubviews()
    }
    
}


// MARK: InnerMethod
extension WKCVideoHorizontalScrollPageView {
    
    /// 初始化, 子类重写此方法
    open func setupSubviews() {
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(videoView)
    }
    
    open func startPlay() {
        guard let value = model else { return }
        WKCVideoHorizontalScrollAfter.shared.invalidate()
        if value.isVideo {
            videoView.startPlay()
        } else {
            WKCVideoHorizontalScrollAfter.shared.after(interval: value.imageDuration) {
                NotificationCenter.default.post(name: NSNotification.Name(WKCImagePlayEndNotification), object: nil)
            }
        }
    }
    
    open func restartPlay() {
        guard let value = model else { return }
        WKCVideoHorizontalScrollAfter.shared.invalidate()
        if value.isVideo {
            videoView.restartPlay()
        } else {
            WKCVideoHorizontalScrollAfter.shared.after(interval: value.imageDuration) {
                NotificationCenter.default.post(name: NSNotification.Name(WKCImagePlayEndNotification), object: nil)
            }
        }
    }
    
    open func stopPlay() {
        videoView.stopPlay()
    }
}
