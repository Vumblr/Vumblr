//
//  StickerFactory.swift
//  Vumblr
//
//  Created by Ken Krzeminski on 10/17/15.
//  Copyright © 2015 Ken Krzeminski. All rights reserved.
//

import UIKit
import AVFoundation


class StickerFactory {
    
    var stickerLayers: [CALayer]?
    
    static let sharedInstance = StickerFactory()
    
    func exportVideoFileFromStickersAndOriginalVideo(stickers: [UIImage], sourceURL: NSURL) {
        AVFoundationClient.sharedInstance.createNewMutableCompositionAndTrack()
        AVFoundationClient.sharedInstance.getSourceAssetFromURL(sourceURL)
        AVFoundationClient.sharedInstance.getVideoParamsAndAppendTracks()
        AVFoundationClient.sharedInstance.createVideoCompositionInstructions()
        for sticker in stickers {
            createStickerLayer(sticker)
        }
        mergeStickerLayersAndFinalizeInstructions()
        AVFoundationClient.sharedInstance.exportVideo(AVFoundationClient.sharedInstance.mutableComposition!, url: <#T##NSURL#>) { (assetURL, error) -> () in
            if assetURL != nil {
                print(assetURL)
            } else {
                print("Error exporting video")
            }
        }
    }
    
    // Needs to accept coordinates. Currently just places the image at 0/0
    func createStickerLayer(image: UIImage) {
        let imageLayer = CALayer()
        let image = image
        imageLayer.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        imageLayer.contents = image.CGImage
        imageLayer.contentsGravity = kCAGravityCenter
        
        //Do the work of setting the layer properties here
        stickerLayers?.append(imageLayer)
    }
    
    func mergeStickerLayersAndFinalizeInstructions() {
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: AVFoundationClient.sharedInstance.renderWidth!, height: AVFoundationClient.sharedInstance.renderHeight!)
        backgroundLayer.masksToBounds = true
        
        for stickerLayer in stickerLayers! {
            backgroundLayer.addSublayer(stickerLayer)
        }
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame =  CGRect(x: 0, y: 0, width: AVFoundationClient.sharedInstance.renderWidth!, height: AVFoundationClient.sharedInstance.renderHeight!)
        videoLayer.frame =  CGRect(x: 0, y: 0, width: AVFoundationClient.sharedInstance.renderWidth!, height: AVFoundationClient.sharedInstance.renderHeight!)
        
        
        parentLayer.addSublayer(backgroundLayer)
        parentLayer.addSublayer(videoLayer)
        
        for stickerLayer in stickerLayers! {
            parentLayer.addSublayer(stickerLayer)
        }
        
        AVFoundationClient.sharedInstance.videoCompositionInstructions!.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
    }

}