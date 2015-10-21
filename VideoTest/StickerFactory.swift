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
    
    var stickerLayers = [CALayer]()
    
    static let sharedInstance = StickerFactory()
    
    func exportVideoFileFromStickersAndOriginalVideo(stickers: [Int:Sticker], sourceURL: NSURL) {
        AVFoundationClient.sharedInstance.createNewMutableCompositionAndTrack()
        AVFoundationClient.sharedInstance.getSourceAssetFromURL(sourceURL)
        AVFoundationClient.sharedInstance.getVideoParamsAndAppendTracks()
        AVFoundationClient.sharedInstance.createVideoCompositionInstructions()
        for (timestamp, sticker) in stickers {
            createStickerLayer(sticker.image!, x: sticker.x!, y: sticker.y!, width: sticker.width!, height: sticker.height!)
        }
        mergeStickerLayersAndFinalizeInstructions()
        
        let filename = "temp_composition.mp4"
        let outputPath = NSTemporaryDirectory().stringByAppendingString(filename)
        let outputUrl = NSURL(fileURLWithPath: outputPath)
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtURL(outputUrl)
        } catch {
            print("Unable to remove item at \(outputUrl)")
        }
        
        
        AVFoundationClient.sharedInstance.exportVideo(AVFoundationClient.sharedInstance.mutableComposition!, url: outputUrl) { (assetURL, error) -> () in
            if assetURL != nil {
                print(assetURL)
                CustomPhotoAlbum.sharedInstance.saveVideo(outputUrl)
            } else {
                print("Error exporting video")
            }
        }
    }
    
    func createStickerLayer(image: UIImage, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(x: x, y: y, width: width, height: height)
        imageLayer.contents = image.CGImage
        imageLayer.contentsGravity = kCAGravityCenter
    
        stickerLayers.append(imageLayer)
    }
    
    func mergeStickerLayersAndFinalizeInstructions() {
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: AVFoundationClient.sharedInstance.renderWidth!, height: AVFoundationClient.sharedInstance.renderHeight!)
        backgroundLayer.masksToBounds = true
        
        for stickerLayer in stickerLayers{
            backgroundLayer.addSublayer(stickerLayer)
        }
        
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame =  CGRect(x: 0, y: 0, width: AVFoundationClient.sharedInstance.renderWidth!, height: AVFoundationClient.sharedInstance.renderHeight!)
        videoLayer.frame =  CGRect(x: 0, y: 0, width: AVFoundationClient.sharedInstance.renderWidth!, height: AVFoundationClient.sharedInstance.renderHeight!)
        
        
        parentLayer.addSublayer(backgroundLayer)
        parentLayer.addSublayer(videoLayer)
        
        for stickerLayer in stickerLayers {
            parentLayer.addSublayer(stickerLayer)
        }
        
        AVFoundationClient.sharedInstance.videoCompositionInstructions!.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
    }
    
}