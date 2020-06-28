//
//  ARCAgingAfter.swift
//  ArtCam
//
//  Created by wkcloveYang on 2020/6/10.
//  Copyright © 2020 wkcloveYang. All rights reserved.
//

import UIKit

public class WKCVideoHorizontalScrollAfter: NSObject {
    
    fileprivate var timer: Timer?
    
    public func after(interval: TimeInterval, completion: (() -> ())?) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { (tim) in
            if let com = completion {
                com()
            }
            tim.invalidate()
        })
    }

    public func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}
