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


class EditVideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate{
    
    var selectedFileUrl: NSURL?
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var trayView: UIView!
    var trayOriginalCenter: CGPoint!
    var trayViewUpY: CGFloat?
    var trayViewDownY: CGFloat?

    @IBOutlet weak var trayArrowImageView: UIImageView!

    
    var newlyCreatedFace: UIImageView!
    var originFaceCenter: CGPoint!
    var customFace: UIImageView!
    var customFaceCenter: CGPoint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trayViewUpY =  CGFloat(560)
        trayViewDownY = CGFloat(745)
        presentPicker()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    

    @IBAction func onPanIconGesture(sender: UIPanGestureRecognizer) {
        
        //var point = sender.locationInView(trayView)
        let translation = sender.translationInView(trayView)
        
        if sender.state == UIGestureRecognizerState.Began {
            let imageView = sender.view as! UIImageView
            newlyCreatedFace = UIImageView(image: imageView.image)
            newlyCreatedFace.userInteractionEnabled = true
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onCustomPan:")
            newlyCreatedFace.addGestureRecognizer(panGestureRecognizer)
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "onCustomPinch:")
            pinchGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(pinchGestureRecognizer)
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "onCustomRotate:")
            newlyCreatedFace.addGestureRecognizer(rotationGestureRecognizer)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onCustomDoubleTap:")
            tapGestureRecognizer.numberOfTapsRequired = 2
            newlyCreatedFace.addGestureRecognizer(tapGestureRecognizer)
            
            view.addSubview(newlyCreatedFace)
            originFaceCenter = imageView.center
            newlyCreatedFace.center = imageView.center
            newlyCreatedFace.center.y += trayView.frame.origin.y
        } else if sender.state == UIGestureRecognizerState.Changed {
            newlyCreatedFace.center = CGPoint(x: originFaceCenter.x + translation.x,
                y: originFaceCenter.y + translation.y + trayView.frame.origin.y)
        } else if sender.state == UIGestureRecognizerState.Ended {
            
        }
    }
    
    @IBAction func onCustomPan(sender: UIPanGestureRecognizer) {
        //var point = sender.locationInView(view)
        let translation = sender.translationInView(view)
        
        
        if sender.state == UIGestureRecognizerState.Began {
            customFace = sender.view as! UIImageView
            customFaceCenter = customFace.center
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.customFace.transform = CGAffineTransformMakeScale(1.25, 1.25)
            })
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            customFace.center = CGPoint(x: customFaceCenter.x + translation.x,
                y: customFaceCenter.y + translation.y )
        } else if sender.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.customFace.transform = CGAffineTransformMakeScale(1, 1 )
            })
        }
        
    }
    
    @IBAction func onCustomPinch(sender: UIPinchGestureRecognizer) {
        customFace = sender.view as! UIImageView
        let scale = sender.scale
        customFace.transform = CGAffineTransformMakeScale(scale, scale)
    }
    
    @IBAction func onCustomRotate(sender: UIRotationGestureRecognizer){
        sender.view!.transform = CGAffineTransformRotate(sender.view!.transform, sender.rotation)
    }
    
    @IBAction func onCustomDoubleTap(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func addSticker() {
        print(selectedFileUrl)
        let mergeComposition : AVMutableComposition = AVMutableComposition()
        let trackVideo : AVMutableCompositionTrack = mergeComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        //var trackAudio : AVMutableCompositionTrack = mergeComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        // 2. Add a bank for theme insertion later
        
        //trackVideo.insertTimeRange(range, ofTrack: VideoHelper.Static.blankTrack, atTime: kCMTimeZero, error: nil)
        
        // 3. Source tracks
        
        let sourceAsset = AVURLAsset(URL: selectedFileUrl!, options: nil)
        let sourceDuration = CMTimeRangeMake(kCMTimeZero, sourceAsset.duration)
        let vtrack: AVAssetTrack? = sourceAsset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
//        let atrack: AVAssetTrack? = sourceAsset.tracksWithMediaType(AVMediaTypeAudio)[0] as AVAssetTrack
        
        if (vtrack == nil) {
            return
        }
        
        let renderWidth = vtrack?.naturalSize.width
        let renderHeight = vtrack?.naturalSize.height
        let insertTime = kCMTimeZero
        let endTime = sourceAsset.duration
        let range = sourceDuration
        
        // append tracks
        do {
            try trackVideo.insertTimeRange(sourceDuration, ofTrack: vtrack!, atTime: insertTime)
        }catch {
            print("error inserting time range")
        }

        // 4. Add subtitles (we call it theme)
        
        let themeVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition(propertiesOfAsset: sourceAsset)
        
        // 4.1 - Create AVMutableVideoCompositionInstruction
        
        let mainInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = range
        
        // 4.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
        
        let videolayerInstruction : AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: trackVideo)
        videolayerInstruction.setTransform(trackVideo.preferredTransform, atTime: insertTime)
        videolayerInstruction.setOpacity(0.0, atTime: endTime)
        
        // 4.3 - Add instructions
        
        mainInstruction.layerInstructions = NSArray(array: [videolayerInstruction]) as! [AVVideoCompositionLayerInstruction]
        
        themeVideoComposition.renderScale = 1.0
        themeVideoComposition.renderSize = CGSizeMake(renderWidth!, renderHeight!)
        themeVideoComposition.frameDuration = CMTimeMake(1, 30)
        themeVideoComposition.instructions = NSArray(array: [mainInstruction]) as! [AVVideoCompositionInstructionProtocol]
        
        // add the theme
        
        // setup variables
        
        // add text
        
        let title = String("💩")
        
        let titleLayer = CATextLayer()
        titleLayer.string = title
        titleLayer.frame =  CGRect(x: 0, y: 0, width: renderWidth!, height: renderHeight!)
        let fontName: CFStringRef = "Helvetica-Bold"
        let fontSize = CGFloat(36)
        titleLayer.font = CTFontCreateWithName(fontName, fontSize, nil)
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.foregroundColor = UIColor.whiteColor().CGColor
        
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: renderWidth!, height: renderHeight!)
        backgroundLayer.masksToBounds = true
        backgroundLayer.addSublayer(titleLayer)
        
        // 2. set parent layer and video layer
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame =  CGRect(x: 0, y: 0, width: renderWidth!, height: renderHeight!)
        videoLayer.frame =  CGRect(x: 0, y: 0, width: renderWidth!, height: renderHeight!)
        
        parentLayer.addSublayer(backgroundLayer)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(titleLayer)
        
        // 3. make animation
        
        themeVideoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
        
        // Remove the file if it already exists (merger does not overwrite)
        let filename = "composition.mp4"
        let outputPath = NSTemporaryDirectory().stringByAppendingString(filename)
        let outputUrl = NSURL(fileURLWithPath: outputPath)
        let fileManager = NSFileManager.defaultManager()
        do {
         try fileManager.removeItemAtURL(outputUrl)
        } catch {
            print("Unable to remove item at \(outputUrl)")
        }
        
        // export to output url
        
        let exporter = AVAssetExportSession(asset: mergeComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter!.outputURL = outputUrl
        print(exporter!.outputURL)
        exporter!.videoComposition = themeVideoComposition
        exporter!.outputFileType = AVFileTypeQuickTimeMovie
        exporter!.shouldOptimizeForNetworkUse = true
        exporter!.exportAsynchronouslyWithCompletionHandler({
            if (exporter!.error != nil) {
                print("Error")
                print(exporter!.error)
                print("Description")
                print(exporter!.description)
            }
            let player = AVPlayer(URL: exporter!.outputURL!)
            let playerController = AVPlayerViewController()
            
            playerController.player = player
            //        self.addChildViewController(playerController)
            self.playerView.addSubview(playerController.view)
            playerController.view.frame = self.playerView.bounds
            
            
            player.play()
//            completionHandler(exporter.status.rawValue)
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
        let fileURL = info["UIImagePickerControllerMediaURL"] as! NSURL
        selectedFileUrl = fileURL
        let player = AVPlayer(URL: fileURL)
        let playerController = AVPlayerViewController()
        
        playerController.player = player
//        self.addChildViewController(playerController)
        playerView.addSubview(playerController.view)
        playerController.view.frame = playerView.bounds
    
        
        player.play()
        
    }
    
    @IBAction func onPanTrayView(sender: UIPanGestureRecognizer) {
        let point = sender.locationInView(trayView)
        let velocity = sender.velocityInView(trayView)
        let translation = sender.translationInView(trayView)

        if sender.state == UIGestureRecognizerState.Began {
            print("Gesture began at: \(point)")
            trayOriginalCenter = trayView.center
        } else if sender.state == UIGestureRecognizerState.Changed {
            print("Gesture changed at: \(point)")
            let newUpY = trayOriginalCenter.y + translation.y
            if newUpY < self.trayViewUpY! {
                trayView.center = CGPoint(x: trayOriginalCenter.x, y: self.trayViewUpY!)
            } else {
                trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            }
        } else if sender.state == UIGestureRecognizerState.Ended {
            print("Gesture ended at: \(point)")
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                if velocity.y > 0 {
                    print("move down", terminator: "")
                    self.trayView.center = CGPoint(x: self.trayOriginalCenter.x, y: self.trayViewDownY!)
                    self.trayArrowImageView.transform =
                        CGAffineTransformMakeRotation(CGFloat(M_PI))
                } else {
                    print("move up", terminator: "")
                    self.trayView.center = CGPoint(x: self.trayOriginalCenter.x, y: self.trayViewUpY!)
                    self.trayArrowImageView.transform = CGAffineTransformMakeRotation(CGFloat(0))
                }
            })
        }
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
