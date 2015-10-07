//
//  ViewController.swift
//  VideoTest
//
//  Created by Ken Krzeminski on 9/26/15.
//  Copyright © 2015 Ken Krzeminski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var workImg: UIImageView!
    @IBOutlet weak var videoImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.videoImg.frame.origin.y -= view.bounds.height
        self.workImg.frame.origin.y -= view.bounds.height
        //self.title.transform = CGAffineTransformScale(self.title.transform, 5, 5)
        //****** ANIMATION PART *******/
        //animation of the video icon
        UIView.animateWithDuration(0.5, animations: {
            self.videoImg.frame.origin.y += self.view.bounds.height
            self.videoImg.alpha = 1
            
        })
        //animation of the works icon
        UIView.animateWithDuration(0.5, delay: 0.3, options: [], animations: {
            self.workImg.frame.origin.y += self.view.bounds.height
            self.workImg.alpha = 1
        }, completion: nil)
        
        UIView.animateWithDuration(0.5, delay: 0.4, options: [], animations: {
            //self.title.center.x += self.view.bounds.width
        }, completion: nil)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.videoImg.alpha = 0
        self.workImg.alpha = 0
        
        self.navigationController?.navigationBarHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

