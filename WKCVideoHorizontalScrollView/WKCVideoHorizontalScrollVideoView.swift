//
//  CMCPlusVideoView.swift
//  EasyTranslate
//
//  Created by star on 2020/1/19.
//  Copyright © 2020 wkcloveYang. All rights reserved.
//

import UIKit
import AVFoundation

@objc open class WKCVideoHorizontalScrollVideoView: UIView {

    @objc open var urls : Array<URL>? {
        didSet {
            self.playerItems.removeAll()
            for url in self.urls ?? [] {
                let item = AVPlayerItem(url: url)
                self.playerItems.append(item)
            }
            self.player.replaceCurrentItem(with: self.playerItems.first)
            self.player.seek(to: .zero)
        }
    }
    open var videoSize : CGSize?
    @objc open var isRepeated : Bool = true
    @objc open var autoPlayWhenAppBeActive : Bool = true
    @objc open var isAutoPlayNext : Bool = true
    @objc open var playCompletion : () -> Void = {}
    @objc open var playLoopCompletion : () -> Void = {}
    @objc open var isPlaying: Bool = false
    
    fileprivate lazy var playerItems : Array<AVPlayerItem> = {
        var playerItems = Array<AVPlayerItem>()
        for url in self.urls ?? [] {
            let item = AVPlayerItem(url: url)
            playerItems.append(item)
        }
        return playerItems
    }()
    
    fileprivate lazy var player : AVPlayer = {
        let player = AVPlayer(playerItem: self.playerItems.first)
        let layer = AVPlayerLayer(player: player)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.videoGravity = .resizeAspectFill
        layer.frame = CGRect(origin: .zero, size: self.videoSize ?? CGSize.zero)
        self.layer.addSublayer(layer)
        return player
    }()
    
    @objc public init(urls: Array<URL>, size: CGSize) {
        self.urls = urls
        self.videoSize = size
        super.init(frame: .zero)
        self.initViews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func initViews() {
        NotificationCenter.default.addObserver(self, selector: #selector(completePlay(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBeActive(notifcation:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBack(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        self.player.seek(to: .zero)        
    }
    
    @objc open func startPlay() {
        self.player.play()
        isPlaying = true
    }
    
    @objc open func restartPlay() {
        self.player.seek(to: .zero)
        self.player.play()
        isPlaying = true
    }
    
    @objc open func stopPlay() {
        self.player.pause()
        isPlaying = false
    }
    
    @objc fileprivate func completePlay(notification: Notification) {
        var index = self.playerItems.firstIndex(of: notification.object as! AVPlayerItem)
        
        if index != nil {
            index! += 1
            if index! >= self.playerItems.count {
                if !self.isRepeated {
                    self.playCompletion()
                    return
                }
                index = 0
            }
            
            self.playLoopCompletion()
            
            if (self.isAutoPlayNext) {
                self.player.replaceCurrentItem(with: self.playerItems[index!])
                self.player.play()
                isPlaying = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.player.replaceCurrentItem(with: self.playerItems[index!])
                    self.isPlaying = false
                }
            }
        }
    }
    
    @objc fileprivate func applicationBeActive(notifcation: Notification) {
        if self.autoPlayWhenAppBeActive {
            self.startPlay()
        }
    }
    
    @objc fileprivate func applicationEnterBack(notification: Notification) {
        if (self.autoPlayWhenAppBeActive) {
            self.stopPlay()
        }
    }
}
