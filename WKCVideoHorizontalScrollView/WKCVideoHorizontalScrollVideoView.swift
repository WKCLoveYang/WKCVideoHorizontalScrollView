//
//  CMCPlusVideoView.swift
//  EasyTranslate
//
//  Created by star on 2020/1/19.
//  Copyright © 2020 wkcloveYang. All rights reserved.
//

import UIKit
import AVFoundation

public let kWKCVideoPlayEndNotification: String = "wkc.video.play.end"

@objc open class WKCVideoHorizontalScrollVideoView: UIView {

    @objc open var url : URL? {
        willSet {
            if let value = newValue {
                let item = AVPlayerItem(url: value)
                self.player.replaceCurrentItem(with: item)
                self.player.seek(to: .zero)
            }
        }
    }
    
    @objc open var isPlaying: Bool = false
    
    fileprivate var playItem: AVPlayerItem?
    fileprivate var videoSize: CGSize?
    
    fileprivate lazy var player : AVPlayer = {
        let player = AVPlayer(playerItem: playItem)
        let layer = AVPlayerLayer(player: player)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.videoGravity = .resizeAspectFill
        layer.frame = CGRect(origin: .zero, size: videoSize ?? CGSize.zero)
        self.layer.addSublayer(layer)
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: CMTimeScale(NSEC_PER_SEC)), queue: nil) { [weak self] (cmtime) in
            if let weakSelf = self {
                let progress = cmtime.seconds / CMTimeGetSeconds(weakSelf.playItem!.duration)
                if (progress >= 1.0) {
                    NotificationCenter.default.post(name: NSNotification.Name(kWKCVideoPlayEndNotification), object: nil)
                    weakSelf.isPlaying = false
                }
            }
        }
        return player
    }()
    
    @objc public init(url: URL?, size: CGSize) {
        self.url = url
        self.videoSize = size
        super.init(frame: .zero)
        self.player.seek(to: .zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
