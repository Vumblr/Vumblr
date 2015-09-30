//
//  PlayVideoViewController.swift
//  VideoTest
//
//  Created by Ken Krzeminski on 9/26/15.
//  Copyright © 2015 Ken Krzeminski. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices


class PlayVideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        self.dismissViewControllerAnimated(true, completion: nil)
        let player = AVPlayer(URL: info["UIImagePickerControllerMediaURL"] as! NSURL)
        let playerController = AVPlayerViewController()
        
        playerController.player = player
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        playerController.view.frame = self.view.frame
        
        player.play()
        
    }
    
    

    @IBAction func onTapPlayVideo(sender: AnyObject) {
        let ipcVideo = UIImagePickerController()
        ipcVideo.delegate = self
        ipcVideo.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        let kUTTypeMovieAnyObject : String = kUTTypeMovie as String
        ipcVideo.mediaTypes = [kUTTypeMovieAnyObject]
        self.presentViewController(ipcVideo, animated: true, completion: nil)
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
