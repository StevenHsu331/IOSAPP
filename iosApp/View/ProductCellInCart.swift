//
//  ProductCellInCart.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/10.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit


class ProductCellInCart: UITableViewCell{
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    override func awakeFromNib() {
        name.textColor = .white
        price.textColor = .white
        amount.textColor = .white
    }
}
