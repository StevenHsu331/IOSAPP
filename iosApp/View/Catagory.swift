//
//  Catagory.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/10.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class Catagory: UICollectionViewCell{
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        background.layer.cornerRadius = 12
        image.layer.cornerRadius = 12
    }
}
