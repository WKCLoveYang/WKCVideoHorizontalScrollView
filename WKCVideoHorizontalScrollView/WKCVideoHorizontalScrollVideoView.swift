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

public class WKCVideoHorizontalScrollVideoView: UIView {

    public var url : URL? {
        willSet {
            if let value = newValue {
                let item = AVPlayerItem(url: value)
                playItem = item
                player.replaceCurrentItem(with: item)
                player.seek(to: .zero)
            }
        }
    }
    
    internal var notificationIdentify: String?
    
    internal var isPlaying: Bool = false
    
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
                    NotificationCenter.default.post(name: NSNotification.Name(kWKCVideoPlayEndNotification), object: weakSelf.notificationIdentify)
                    weakSelf.isPlaying = false
                }
            }
        }
        return player
    }()
    
    public init(url: URL?, size: CGSize) {
        self.url = url
        self.videoSize = size
        super.init(frame: .zero)
        self.player.seek(to: .zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func startPlay() {
        player.play()
        isPlaying = true
    }
    
    internal func restartPlay() {
        player.seek(to: .zero)
        player.play()
        isPlaying = true
    }
    
    internal func stopPlay() {
        player.pause()
        isPlaying = false
    }
}
