//
//  PhotoDetailViewController.swift
//  Flowers_sfy
//
//  Created by Alba Bussalleu on 24/10/21.
//

import Foundation
import UIKit

open class PhotoDetailViewController
: UIViewController{
    @IBOutlet weak var imgDetail: UIImageView!
    
    var photoData : UIImage?
    
     override open func viewDidLoad()
        {
            super.viewDidLoad()
            imgDetail.image = photoData
        }
    
   
}
