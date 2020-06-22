//
//  WKCVideoHorizontalScrollBaseModel.swift
//  SwfitTest
//
//  Created by wkcloveYang on 2020/6/19.
//  Copyright © 2020 wkcloveYang. All rights reserved.
//

import UIKit

open class WKCVideoHorizontalScrollBaseModel: NSObject, Codable {

    open var image: String?
    open var video: String?
    open var isVideo: Bool! {
        return video != nil
    }
    open var imageDuration: TimeInterval = 3
    
}
