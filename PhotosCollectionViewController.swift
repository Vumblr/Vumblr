//
//  PhotosCollectionViewController.swift
//  Vumblr
//
//  Created by Lea Sabban on 10/8/15.
//  Copyright © 2015 Ken Krzeminski. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class PhotosCollectionViewController: UICollectionViewController, PHPhotoLibraryChangeObserver {
    
    var videos: PHFetchResult! = nil
    let imageManager = PHCachingImageManager.defaultManager()
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nav = self.navigationController?.navigationBar
        
        ///******* UI OF TOP BAR Collection view *******/
        navigationItem.title = "Videos"
        //navigationItem.
        //nav?.titleTextAttributes = UIColor.whiteColor()
        nav?.tintColor = UIColor.whiteColor()
        nav?.barTintColor = UIColor(red: 253/255, green: 58/255, blue: 90/255, alpha: 1)
        nav?.translucent = false
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if(videos != nil) {
            return videos.count
        }
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
