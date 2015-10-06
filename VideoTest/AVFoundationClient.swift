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
    
    class var sharedInstance : AVFoundationClient {
        struct Static {
            static let instance =  AVFoundationClient()
        }
        return Static.instance
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
