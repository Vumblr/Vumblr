//
//  PhotosCollectionViewController.swift
//  Vumblr
//
//  Created by Lea Sabban on 10/8/15.
//  Copyright © 2015 Ken Krzeminski. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import MediaPlayer
import AVKit

private let reuseIdentifier = "Cell"

class PhotosCollectionViewController: UIViewController, PHPhotoLibraryChangeObserver, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var videos: PHFetchResult! = nil
    let imageManager = PHCachingImageManager.defaultManager()
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 50.0, right: 20.0)
    

    
    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) == false {
            return false
        }
        
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .Camera
        cameraController.mediaTypes = [kUTTypeMovie as String]
        cameraController.allowsEditing = true
        cameraController.delegate = self
        
        presentViewController(cameraController, animated: true, completion: nil)
        return true
    }
    
    
    @IBAction func onTapVideo(sender: UIPanGestureRecognizer) {
        print("on tap record")
        startCameraFromViewController(self, withDelegate: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let nav = self.navigationController?.navigationBar
        collectionView.delegate = self
        collectionView.dataSource = self
        ///******* UI OF TOP BAR Collection view *******/
        //navigationItem.
        //nav?.titleTextAttributes = UIColor.whiteColor()
        nav?.tintColor = UIColor.whiteColor()
        navigationItem.title = "Videos"

        nav?.barTintColor = UIColor(red: 253/255, green: 58/255, blue: 90/255, alpha: 1)
        //nav?.translucent = falsvar
        self.navigationController?.navigationBarHidden = false
        let allVideosOptions = PHFetchOptions()
        allVideosOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Video.rawValue)
        allVideosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        videos = PHAsset.fetchAssetsWithOptions(allVideosOptions)

        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }

    //3
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        videos = nil
        // Dispose of any resources that can be recreated.
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString

        if mediaType.isEqualToString(kUTTypeImage as String) {

            // Media is an image

        } else if mediaType.isEqualToString(kUTTypeMovie as String) {

            //let url = info[UIImagePickerControllerMediaURL]
            
            let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path!) {
                UISaveVideoAtPathToSavedPhotosAlbum(path!, self, "video:didFinishSavingWithError:contextInfo:", nil)
            }
            
        }

    }
    
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("viewVideo2", sender: videoPath)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if(videos != nil) {
            return videos.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotosCollectionViewCell
        // Configure the cell
        cell.imageManager = imageManager
        cell.imageAsset = videos[indexPath.item] as? PHAsset
        
        return cell
    }
    
    func photoLibraryDidChange(changeInstance: PHChange!) {
        if let changeDetails = changeInstance.changeDetailsForFetchResult(videos) {
            
            dispatch_async(dispatch_get_main_queue()) {
                self.videos = changeDetails.fetchResultAfterChanges
                self.collectionView?.reloadData()
            }
        }
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "viewVideo"){
            print("hhelkdklfd")
            let controller:EditVideoViewController = segue.destinationViewController as! EditVideoViewController
            let indexPath: NSIndexPath = (self.collectionView?.indexPathForCell(sender as! UICollectionViewCell))!
            controller.videos = self.videos
            controller.index = indexPath.item
            
            //controller.imageManager = self.imageManager
        }
        
        if(segue.identifier == "viewVideo2"){
            print("View 2")
            let controller:EditVideoViewController = segue.destinationViewController as! EditVideoViewController
            print(sender)
            controller.videos = self.videos
            controller.selectedFileUrl = NSURL(fileURLWithPath: sender as! String)
            //controller.imageManager = self.imageManager
        }
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    
    
    
//    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
//        var title = "Success"
//        var message = "Video was saved"
//        
//        if let saveError = error {
//            title = "Error: \(saveError)"
//            message = "Video failed to save"
//        }
//        
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
//        presentViewController(alert, animated: true, completion: nil)
//    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//        
//        // Code here to work with media
//        print("FINISHHHH")
//        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
//        
//        if mediaType.isEqualToString(kUTTypeImage as! String) {
//            
//            // Media is an image
//            
//        } else if mediaType.isEqualToString(kUTTypeMovie as! String) {
//            
//            let url = info[UIImagePickerControllerMediaURL]
//            print(url)
//
//        }
//       
//               //self.dismissViewControllerAnimated(true, completion: nil)
//    }
    

}


