//
//  RecordVideoViewController.swift
//  AVFoundationDemo
//
//  Created by Andy (Liang) Dong on 9/27/15.
//  Copyright © 2015 codepath. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaPlayer
import AVKit

class RecordVideoViewController: UIViewController {
    
    
    @IBOutlet weak var recordImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) == false {
            return false
        }
        
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .Camera
        cameraController.mediaTypes = [kUTTypeMovie as String]
        cameraController.allowsEditing = false
        cameraController.delegate = delegate
        
        presentViewController(cameraController, animated: true, completion: nil)
        return true
    }
    
    @IBAction func onRecordVideoButton(sender: UIButton) {
        print("click on record video button")
        startCameraFromViewController(self, withDelegate: self)
    }
    
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        var title = "Success"
        var message = "Video was saved"
        
        if let saveError = error {
            title = "Error: \(saveError)"
            message = "Video failed to save"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
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

extension RecordVideoViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        dismissViewControllerAnimated(true, completion: nil)
        // Handle a movie capture
        
        if mediaType == kUTTypeMovie as String {
            let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path!) {
                UISaveVideoAtPathToSavedPhotosAlbum(path!, self, "video:didFinishSavingWithError:contextInfo:", nil)
            }
        }
        
    }
}

extension RecordVideoViewController: UINavigationControllerDelegate {
}
