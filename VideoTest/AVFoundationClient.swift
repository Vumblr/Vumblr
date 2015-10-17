//
//  AVFoundationClient.swift
//
//
//  Created by Andy (Liang) Dong on 10/4/15.
//  Copyright © 2015 codepath. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import CoreMedia
import Photos

class AVFoundationClient {
    
    var selectedVideoURL: NSURL?
    var mutableComposition: AVMutableComposition?
    var videoCompositionInstructions: AVMutableVideoComposition?
    var videoTrack: AVMutableCompositionTrack?
    var sourceAsset: AVURLAsset?
    var insertTime = kCMTimeZero
    var sourceVideoAsset: AVAsset?
    var sourceVideoTrack: AVAssetTrack?
    var sourceRange: CMTimeRange?
    var renderWidth: CGFloat?
    var renderHeight: CGFloat?
    var endTime: CMTime?

    
    class var sharedInstance : AVFoundationClient {
        struct Static {
            static let instance =  AVFoundationClient()
        }
        return Static.instance
    }
    
    
    func createNewMutableCompositionAndTrack() {
        mutableComposition = AVMutableComposition()
        videoTrack = mutableComposition!.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
    }
    
    func getSourceAssetFromURL(fileURL: NSURL) {
        sourceAsset = AVURLAsset(URL: fileURL, options: nil)
    }
    
    func getVideoParamsAndAppendTracks() {
        let sourceDuration = CMTimeRangeMake(kCMTimeZero, sourceAsset!.duration)
        
        sourceVideoTrack = sourceAsset!.tracksWithMediaType(AVMediaTypeVideo)[0]
        renderWidth = sourceVideoTrack?.naturalSize.width
        renderHeight = sourceVideoTrack?.naturalSize.height
        endTime = sourceAsset!.duration
        sourceRange = sourceDuration
        
        // Appending the tracks
        do {
            try videoTrack!.insertTimeRange(sourceDuration, ofTrack: sourceVideoTrack!, atTime: insertTime)
        }catch {
            print("error inserting time range")
        }
    }
    
    func createVideoCompositionInstructions() {
        videoCompositionInstructions = AVMutableVideoComposition(propertiesOfAsset: sourceAsset!)
        
        let mainInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = sourceRange!
        
        let videolayerInstruction = videoCompositionInstructionForTrack(videoTrack!, asset: sourceAsset!, scaleRatio: 1)
        videolayerInstruction.setTransform(videoTrack!.preferredTransform, atTime: insertTime)
        videolayerInstruction.setOpacity(0.0, atTime: endTime!)
        
        
        //Add instructions
        mainInstruction.layerInstructions = NSArray(array: [videolayerInstruction]) as! [AVVideoCompositionLayerInstruction]
        
        videoCompositionInstructions!.renderScale = 1.0
        videoCompositionInstructions!.renderSize = CGSizeMake(renderWidth!, renderHeight!)
        videoCompositionInstructions!.frameDuration = CMTimeMake(1, 30)
        videoCompositionInstructions!.instructions = NSArray(array: [mainInstruction]) as! [AVVideoCompositionInstructionProtocol]
        
    }
    
    
    
    func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.Up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .Right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .Left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .Up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .Down
        }
        return (assetOrientation, isPortrait)
    }
    
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset, scaleRatio : CGFloat) -> AVMutableVideoCompositionLayerInstruction {
        // 1
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        // 2
        let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
        
        // 3
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        var scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.width
        
        if assetInfo.isPortrait {
            // 4
            scaleToFitRatio = (UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.height * scaleRatio)
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            instruction.setTransform(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor),
                atTime: kCMTimeZero)
        } else {
            // 5
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio * scaleRatio, scaleToFitRatio * scaleRatio)
            var concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.width / 2))
            if assetInfo.orientation == .Down {
                let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
                let windowBounds = UIScreen.mainScreen().bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
                concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
            }
            instruction.setTransform(concat, atTime: kCMTimeZero)
        }
        
        return instruction
    }
    
    func exportVideo(composition: AVComposition, url: NSURL, completion: (assetURL: NSURL!, error: NSError?) -> ()) {
        if let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) {
            exporter.outputURL = url
            exporter.outputFileType = AVFileTypeQuickTimeMovie
            exporter.shouldOptimizeForNetworkUse = true
            
            // Perform the Export
            exporter.exportAsynchronouslyWithCompletionHandler() {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //self.exportDidFinish(exporter)
                    if exporter.status == AVAssetExportSessionStatus.Completed {
                        if let outputURL = exporter.outputURL {
                            let library = ALAssetsLibrary()
                            if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL) {
                                library.writeVideoAtPathToSavedPhotosAlbum(outputURL,
                                    completionBlock: completion)
                            }
                        }
                    }
                })
            }
        }
    }
    
}
