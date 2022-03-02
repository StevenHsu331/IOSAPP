//
//  additionalPurchase.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/25.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class AdditionalPurchase: UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var amountBtn: UIStepper!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var price: UILabel!
    var didCheck = false
    var addedValue: Int = 0
    var section: Int = 0
    let tools = Tools()
    
    override func awakeFromNib() {
        self.layer.backgroundColor = tools.getRGB(r: 49, g: 49, b: 49)
        amount.text = "1"
        name.textColor = .white
        price.textColor = .white
        amount.textColor = .white
        amountBtn.tintColor = .white
        amountBtn.minimumValue = 1
        amountBtn.maximumValue = 20
        amountBtn.stepValue = 1
        amountBtn.autorepeat = true
        amountBtn.wraps = true
    }
    
    @IBAction func changeAmount(_ sender: Any) {
        amount.text = String(Int(amountBtn.value))
    }
    
    @IBAction func check(_ sender: Any) {
        let navigator = tools.getTopMostViewController() as! UINavigationController
        let vc = navigator.viewControllers.first as! SendOrderViewController
        
        if !self.didCheck{
            if let image = UIImage(systemName: "checkmark.square"){
                checkBox.setImage(image, for: .normal)
                didCheck = true
                
                if price.text != "0"{
                    vc.priceValues[self.section] += Int(price.text!)! * Int(amount.text!)!
                    vc.totalPriceValue += Int(price.text!)! * Int(amount.text!)!
                    vc.totalPrice.text = "total cost: " + String(vc.totalPriceValue)
                    vc.purchases.reloadData()
                    self.addedValue += Int(price.text!)! * Int(amount.text!)!
                }
            }
        }
        else{
            if let image = UIImage(systemName: "square"){
                checkBox.setImage(image, for: .normal)
                didCheck = false
                
                if price.text != "0"{
                    vc.priceValues[self.section] -= self.addedValue
                    vc.totalPriceValue -= self.addedValue
                    vc.totalPrice.text = "total cost: " + String(vc.totalPriceValue)
                    vc.purchases.reloadData()
                    self.addedValue = 0
                }
            }
        }
    }
}
