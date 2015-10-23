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
import Photos

class EditVideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate{
    
    var selectedFileUrl: NSURL?
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var trayView: UIView!
    var trayOriginalCenter: CGPoint!
    var trayViewUpY: CGFloat?
    var trayViewDownY: CGFloat?

    @IBOutlet weak var trayArrowImageView: UIImageView!

    
    var newlyCreatedFace: UIImageView!
    var customFace: UIImageView!
    var originFaceCenter: CGPoint!
    var customFaceCenter: CGPoint!
    
    
    var playViewGapY: CGFloat = 64
    var videoBounds: CGRect?
    var customIconArray = [UIImageView]()
    
    var videos: PHFetchResult! = nil
    var videoAsset: PHAsset?
    var assetCollection: PHAssetCollection = PHAssetCollection()
    var index: Int = 0
    var stickerDictionary = [Int:Sticker]()   // key: timestamp, value: sticker
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trayViewUpY =  CGFloat(560)
        trayViewDownY = CGFloat(745)
        //presentPicker()

        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        print("view will appear")
        print(selectedFileUrl)
        self.retreiveVideoURL()
       
    }
    
    func retreiveVideoURL() {
        videoAsset = videos[index] as? PHAsset
        let imageManager = PHImageManager.defaultManager()
        
        var id = imageManager.requestAVAssetForVideo(videoAsset!, options: nil) { (asset: AVAsset?, audioMix: AVAudioMix?, info: [NSObject : AnyObject]?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
            if let asset = asset as? AVURLAsset {
                print("assets URL")
                if self.selectedFileUrl == nil {
                    self.selectedFileUrl = asset.URL
                }
                
                let player = AVPlayer(URL: self.selectedFileUrl!)
                let playerController = AVPlayerViewController()
                
                
                playerController.player = player
                //self.addChildViewController(playerController)
                self.playerView.addSubview(playerController.view)
                playerController.view.frame = self.playerView.bounds
                
                self.videoBounds = self.playerView.bounds
                self.playerView.translatesAutoresizingMaskIntoConstraints = false
                player.play()

            }
            })
        }
    }

    @IBAction func onPanIconGesture(sender: UIPanGestureRecognizer) {
        
        //var point = sender.locationInView(trayView)
        let translation = sender.translationInView(trayView)
        
        if sender.state == UIGestureRecognizerState.Began {
            let imageView = sender.view as! UIImageView
            newlyCreatedFace = UIImageView(image: imageView.image)
            newlyCreatedFace.userInteractionEnabled = true
            newlyCreatedFace.multipleTouchEnabled = true
            
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
            setIconConstraint(newlyCreatedFace)
            let timestamp = Int(NSDate().timeIntervalSince1970)
            newlyCreatedFace.tag = timestamp
            let sticker = Sticker()
            sticker.timestamp = timestamp
            sticker.image = newlyCreatedFace.image
            sticker.setInit()
            sticker.updateStickerRect(newlyCreatedFace, paddingTop: playViewGapY)
            stickerDictionary[timestamp] = sticker
            debugStickers()
        }
    }

    
    @IBAction func onCustomPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        if sender.state == UIGestureRecognizerState.Began {
            customFace = sender.view as! UIImageView
            customFace.userInteractionEnabled = true
            customFace.multipleTouchEnabled = true
            customFaceCenter = customFace.center
//            UIView.animateWithDuration(0.2, animations: { () -> Void in
//                self.customFace.transform = CGAffineTransformMakeScale(1.5, 1.5)
//            })
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            customFace.center = CGPoint(x: customFaceCenter.x + translation.x,
                y: customFaceCenter.y + translation.y )
        } else if sender.state == UIGestureRecognizerState.Ended {
//            UIView.animateWithDuration(0.2, animations: { () -> Void in
//                self.customFace.transform = CGAffineTransformMakeScale(1, 1 )
//            })
            setIconConstraint(customFace)
            let timestamp = customFace.tag
            if let sticker = stickerDictionary[timestamp] {
                sticker.updateStickerRect(customFace, paddingTop: playViewGapY)
                stickerDictionary[timestamp] = sticker
            }
            debugStickers()
        }
    }
    
    
    func debugStickers() {
        if let vBounds = videoBounds {
            print("videoFrameSize \(vBounds)")
            for (_, sticker) in stickerDictionary {
                print(sticker.toString() + "\n")
            }
        }
    }
    
    func setIconConstraint(imageView : UIImageView) {
        if let vBounds = videoBounds {
            if (imageView.center.x - imageView.bounds.width / 2 < 0) {
                imageView.center.x = imageView.bounds.width / 2
            }
            if (imageView.center.x + imageView.bounds.width / 2 > vBounds.width) {
                imageView.center.x = vBounds.width - imageView.bounds.width / 2
            }
            if (imageView.center.y - imageView.bounds.height / 2 < playViewGapY) {
                imageView.center.y = imageView.bounds.height / 2 + playViewGapY
            }
            if (imageView.center.y + imageView.bounds.height / 2 > vBounds.height + playViewGapY) {
                imageView.center.y = vBounds.height - imageView.bounds.height / 2 + playViewGapY
            }
        }
    }
    
    @IBAction func onCustomPinch(recognizer: UIPinchGestureRecognizer) {
        
        customFace = recognizer.view as? UIImageView
        customFace.userInteractionEnabled = true
        customFace.multipleTouchEnabled = true

        customFace.transform = CGAffineTransformScale(customFace.transform,recognizer.scale,recognizer.scale)
        
        let timestamp = customFace.tag
        if let sticker = stickerDictionary[timestamp] {
            sticker.scale = sticker.scale! * recognizer.scale
            stickerDictionary[timestamp] = sticker
        }
        
        recognizer.scale = 1
        
        debugStickers()
        
    }
    
    @IBAction func onCustomRotate(recognizer: UIRotationGestureRecognizer){
        customFace = recognizer.view as? UIImageView
        customFace.userInteractionEnabled = true
        customFace.multipleTouchEnabled = true
        
        let timestamp = customFace.tag
        if let sticker = stickerDictionary[timestamp] {
            sticker.rotation = sticker.rotation! + recognizer.rotation
            stickerDictionary[timestamp] = sticker
        }

        customFace.transform = CGAffineTransformRotate(customFace.transform, recognizer.rotation)
        recognizer.rotation = 0

        debugStickers()
    }
    
    @IBAction func onCustomDoubleTap(sender: UITapGestureRecognizer) {
        customFace = sender.view as? UIImageView
        let timestamp = customFace.tag
        stickerDictionary.removeValueForKey(timestamp)
        customFace.removeFromSuperview()
        
        debugStickers()
    }
    
    @IBAction func onTapExport(sender: AnyObject) {
        if stickerDictionary.count > 0 {
            StickerFactory.sharedInstance.exportVideoFileFromStickersAndOriginalVideo(stickerDictionary, sourceURL: selectedFileUrl!)
            
            let alertController = UIAlertController(title: "Exported Video!", message:
                "Video exported to the 'Vumblr' album", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)

        } else {
            let alertController = UIAlertController(title: "Add some stickers first!", message:
                "Add stickers to your video before attempting to export the video", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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

        playerView.addSubview(playerController.view)
        playerController.view.frame = playerView.bounds
    
        videoBounds = playerView.bounds

        //stickerDictionary.removeAll()
        stickerDictionary = [Int:Sticker]()
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

    }
    
}
