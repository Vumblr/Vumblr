//
//  MergeVideoViewController.swift
//  AVFoundationDemo
//
//  Created by Andy (Liang) Dong on 9/27/15.
//  Copyright © 2015 codepath. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import CoreMedia
import Photos

class MergeVideoViewController: UIViewController {
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var audioAsset: AVAsset?
    var loadingAssetOne = false
    
    //@IBOutlet var activityMonitor: UIActivityIndicatorView!
    
    var assetCollection: PHAssetCollection = PHAssetCollection()
    var photosAsset: PHFetchResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func savedPhotosAvailable() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) == false {
            let alert = UIAlertController(title: "Not Available", message: "No Saved Album found", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func startMediaBrowserFromViewController(viewController: UIViewController!, usingDelegate delegate : protocol<UINavigationControllerDelegate, UIImagePickerControllerDelegate>!) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) == false {
            return false
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .SavedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        presentViewController(mediaUI, animated: true, completion: nil)
        return true
    }
    
    @IBAction func loadAssetOne(sender: AnyObject) {
        if savedPhotosAvailable() {
            loadingAssetOne = true
            startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    
    @IBAction func loadAssetTwo(sender: AnyObject) {
        if savedPhotosAvailable() {
            loadingAssetOne = false
            startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    
    @IBAction func loadAudio(sender: AnyObject) {
        let mediaPickerController = MPMediaPickerController(mediaTypes: .Music)
        mediaPickerController.delegate = self
        mediaPickerController.prompt = "Select Audio"
        presentViewController(mediaPickerController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func merge(sender: AnyObject) {
        if let firstAsset = firstAsset, secondAsset = secondAsset {
            //activityMonitor.startAnimating()
            
            // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
            let mixComposition = AVMutableComposition()
            
            // 2 - Video track
            let originVideoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            
            do {
                try originVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration),
                    ofTrack: firstAsset.tracksWithMediaType(AVMediaTypeVideo)[0],
                    atTime: kCMTimeZero)
            } catch _ {
                print("video one failed")
            }
            
            let decorativeVideoTrak = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            do {
                
                try decorativeVideoTrak.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration),
                    ofTrack: secondAsset.tracksWithMediaType(AVMediaTypeVideo)[0],
                    atTime: kCMTimeZero)
                //atTime: firstAsset.duration)
            } catch _ {
                print("video two failed")
            }
            
            // 2.1
            let mainInstruction = AVMutableVideoCompositionInstruction()
            //mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration))
            mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMaximum(firstAsset.duration, secondAsset.duration))
            
            // 2.2
            let firstInstruction = AVFoundationClient.sharedInstance.videoCompositionInstructionForTrack(originVideoTrack, asset: firstAsset, scaleRatio: 1.0)
            firstInstruction.setOpacity(0.0, atTime: firstAsset.duration)
            let secondInstruction = AVFoundationClient.sharedInstance.videoCompositionInstructionForTrack(decorativeVideoTrak, asset: secondAsset, scaleRatio: 0.5)
            
            // 2.3
            mainInstruction.layerInstructions = [secondInstruction, firstInstruction]
            
            let mainComposition = AVMutableVideoComposition()
            mainComposition.instructions = [mainInstruction]
            mainComposition.frameDuration = CMTimeMake(1, 30)
            mainComposition.renderSize = CGSize(width: UIScreen.mainScreen().bounds.width,
                height: UIScreen.mainScreen().bounds.height)
            
            // 3 - Audio track
            if let loadedAudioAsset = audioAsset {
                let audioTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: 0)
                
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)), ofTrack: loadedAudioAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: kCMTimeZero)
                } catch _ {
                    print("Audio failed")
                }
            }
            
            // 4 - Get path
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat="yyyyMMddHHmmss"
            let date = dateFormatter.stringFromDate(NSDate())
            
            //            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            //            let savePath = documentDirectory.stringByAppendingString("mergeVideo-\(date).mov")
            
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let url = documentsURL.URLByAppendingPathComponent("mergeVideo-\(date).mov")
            print("SavePath is \(url)")
            
            
            
            
            
            
            // 5 - Create Exporter
            if let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                exporter.outputURL = url
                exporter.outputFileType = AVFileTypeQuickTimeMovie
                exporter.shouldOptimizeForNetworkUse = true
                exporter.videoComposition = mainComposition
                
                // 6 - Perform the Export
                exporter.exportAsynchronouslyWithCompletionHandler() {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.exportDidFinish(exporter)
                    })
                }
            }
        }
        
        
    }
    
    func exportDidFinish(session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.Completed {
            if let outputURL = session.outputURL {
                let library = ALAssetsLibrary()
                if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL) {
                    library.writeVideoAtPathToSavedPhotosAlbum(outputURL,
                        completionBlock: { (assetURL:NSURL!, error:NSError!) -> Void in
                            var title = ""
                            var message = ""
                            if error != nil {
                                title = "Error"
                                message = "Failed to save video"
                            } else {
                                title = "Success"
                                message = "Video saved"
                            }
                            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
                
                
            }
        }
        
        //activityMonitor.stopAnimating()
        firstAsset = nil
        secondAsset = nil
        audioAsset = nil
    }
    
    
    @IBAction func onClickMergeAllAPI(sender: UIButton) {
        let mixComposition = AVMutableComposition()
        
        // Create export URL
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat="yyyyMMddHHmmss"
        let date = dateFormatter.stringFromDate(NSDate())
        
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let url = documentsURL.URLByAppendingPathComponent("mergeVideo-\(date).mov")
        print("SavePath is \(url)")
        
        // Export
        AVFoundationClient.sharedInstance.exportVideo(mixComposition, url: url, completion: { (assetURL, error) -> () in
            var title = ""
            var message = ""
            if error != nil {
                title = "Error"
                message = "Failed to save video"
            } else {
                title = "Success"
                message = "Video saved"
            }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        })
        
        
    }
    
    
    
    
}

extension MergeVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = AVAsset(URL: info["UIImagePickerControllerMediaURL"] as! NSURL)
            var message = ""
            if loadingAssetOne {
                message = "Video one loaded"
                firstAsset = avAsset
            } else {
                message = "Video two loaded"
                secondAsset = avAsset
            }
            let alert = UIAlertController(title: "Asset Loaded", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension MergeVideoViewController: UINavigationControllerDelegate {
    
}

extension MergeVideoViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let selectedSongs = mediaItemCollection.items
        if selectedSongs.count > 0 {
            let song = selectedSongs[0]
            if let url = song.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL {
                audioAsset = (AVAsset(URL: url) )
                dismissViewControllerAnimated(true, completion: nil)
                let alert = UIAlertController(title: "Asset Loaded", message: "Audio Loaded", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler:nil))
                presentViewController(alert, animated: true, completion: nil)
            } else {
                dismissViewControllerAnimated(true, completion: nil)
                let alert = UIAlertController(title: "Asset Not Available", message: "Audio Not Loaded", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler:nil))
                presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
