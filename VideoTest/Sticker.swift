//
//  Sticker.swift
//  Vumblr
//
//  Created by Ken Krzeminski on 10/20/15.
//  Copyright © 2015 Ken Krzeminski. All rights reserved.
//

import UIKit
import Foundation


class Sticker: NSObject {
    var timestamp: Int?
    var image: UIImage?
    var x: CGFloat?
    var y: CGFloat?
    var height: CGFloat?
    var width: CGFloat?
    var scale: CGFloat?
    var rotation: CGFloat? // radian
    
    func updateSticker(imageView: UIImageView, paddingTop: CGFloat) {
        x = imageView.center.x - imageView.bounds.width / 2
        y = imageView.center.y - imageView.bounds.height / 2 - paddingTop
        width = imageView.bounds.width
        height = imageView.bounds.height
    }
    
    func toString() -> String {
        return "timestamp: \(timestamp), x: \(x), y: \(y), height: \(height), width: \(width), scale: \(scale), rotation:\(rotation)"
    }
}