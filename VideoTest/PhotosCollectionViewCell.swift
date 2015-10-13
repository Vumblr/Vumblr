//
//  PhotosCollectionViewCell.swift
//  Vumblr
//
//  Created by Lea Sabban on 10/8/15.
//  Copyright © 2015 Ken Krzeminski. All rights reserved.
//

import UIKit
import Photos

class PhotosCollectionViewCell: UICollectionViewCell {
    
    
    var imageManager: PHImageManager?
    
    @IBOutlet weak var imageView: UIImageView!

    var imageAsset: PHAsset? {
        didSet {
            self.imageManager?.requestImageForAsset(imageAsset!, targetSize: CGSize(width: 60, height: 60), contentMode: .AspectFill, options: nil) { image, info in
                self.imageView.image = image
            }
        }
    }
}
