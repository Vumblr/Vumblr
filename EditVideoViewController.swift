//
//  EditVideoViewController.swift
//  VideoTest
//
//  Created by Ken Krzeminski on 9/30/15.
//  Copyright © 2015 Ken Krzeminski. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import VideoToolbox


class EditVideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedFileUrl: NSURL?
    
    @IBOutlet weak var playerView: PlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        presentPicker()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addSticker() {
        let composition = AVMutableComposition()
        let vidAsset = AVURLAsset(URL: selectedFileUrl!, options: nil)
        
        // get video track
        let vtrack =  vidAsset.tracksWithMediaType(AVMediaTypeVideo)
        let videoTrack:AVAssetTrack = vtrack[0]
//        let vid_duration = videoTrack.timeRange.duration
        let vid_timerange = CMTimeRangeMake(kCMTimeZero, vidAsset.duration)
        
        let compositionvideoTrack:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        do {
            try compositionvideoTrack.insertTimeRange(vid_timerange, ofTrack: videoTrack, atTime: kCMTimeZero)
        } catch  {
            print("Error inserting time range into \(videoTrack)")
        }
        
        compositionvideoTrack.preferredTransform = videoTrack.preferredTransform
        
        // Set the size of the video
        let size = videoTrack.naturalSize
        
        // Watermark Effect
        
//        
//        let imglogo = UIImage(named: "image.png")
//        let imglayer = CALayer()
//        imglayer.contents = imglogo?.CGImage
//        imglayer.frame = CGRectMake(5, 5, 100, 100)
//        imglayer.opacity = 0.6
//        
        // create text Layer
        let titleLayer = CATextLayer()
        titleLayer.backgroundColor = UIColor.whiteColor().CGColor
        titleLayer.string = "Dummy text"
        titleLayer.font = UIFont(name: "Helvetica", size: 28)
        titleLayer.shadowOpacity = 0.5
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.frame = CGRectMake(0, 50, size.width, size.height / 6)
        
        let videolayer = CALayer()
        videolayer.frame = CGRectMake(0, 0, size.width, size.height)
        
        let parentlayer = CALayer()
        parentlayer.frame = CGRectMake(0, 0, size.width, size.height)
        parentlayer.addSublayer(videolayer)
//        parentlayer.addSublayer(imglayer)
        parentlayer.addSublayer(titleLayer)
        
        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(1, 30)
        layercomposition.renderSize = size
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, inLayer: parentlayer)
        
        // instruction for watermark
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
        let videotrack = composition.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
        instruction.layerInstructions = NSArray(object: layerinstruction) as! [AVVideoCompositionLayerInstruction]
        layercomposition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
        
        //  create new file to receive data
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir: AnyObject = dirPaths[0]
        let movieFilePath = docsDir.stringByAppendingPathComponent("result.mov")
        let movieDestinationUrl = NSURL(fileURLWithPath: movieFilePath)
        
        // use AVAssetExportSession to export video
        let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetHighestQuality)
        assetExport!.outputFileType = AVFileTypeQuickTimeMovie
        assetExport!.outputURL = movieDestinationUrl
        assetExport!.exportAsynchronouslyWithCompletionHandler({
            switch assetExport!.status{
            case  AVAssetExportSessionStatus.Failed:
                print("failed \(assetExport!.error)")
            case AVAssetExportSessionStatus.Cancelled:
                print("cancelled \(assetExport!.error)")
            default:
               print("Movie complete")
                
                
                // play video
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let player = AVPlayer(URL: movieDestinationUrl)
                    let playerController = AVPlayerViewController()
                    
                    playerController.player = player
                    //        self.addChildViewController(playerController)
                    self.playerView.addSubview(playerController.view)
                    playerController.view.frame = self.playerView.bounds
                    
                    
                    player.play()

//                    playerView.playVideo()
                })
            }
        })
    }
    
    func presentPicker() {
        let ipcVideo = UIImagePickerController()
        ipcVideo.delegate = self
        ipcVideo.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        let kUTTypeMovieAnyObject : String = kUTTypeMovie as String
        ipcVideo.mediaTypes = [kUTTypeMovieAnyObject]
        self.presentViewController(ipcVideo, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        self.dismissViewControllerAnimated(true, completion: nil)
        let infoURL = info["UIImagePickerControllerMediaURL"]
        let fileURL = NSURL(fileURLWithPath: "\(infoURL)")
        selectedFileUrl = fileURL
        let player = AVPlayer(URL: fileURL)
        let playerController = AVPlayerViewController()
        
        playerController.player = player
//        self.addChildViewController(playerController)
        playerView.addSubview(playerController.view)
        playerController.view.frame = playerView.bounds
    
        
        player.play()
        
    }
    
    @IBAction func onClickAddSticker(sender: AnyObject) {
        print("Added sticker")
        addSticker()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
