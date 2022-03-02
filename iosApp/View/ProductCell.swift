//
//  ProductCell.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/10.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell{
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var amountBtn: UIStepper!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var addBtn: UIButton!
    
    var restaurantName: String = ""
    var restaurantId: String = ""
    let tools = Tools()
    
    @IBAction func addAmount(_ sender: Any) {
        amount.text = String(Int(amountBtn.value))
    }
    
    @IBAction func addToCart(_ sender: Any) {
        
        let param = tools.toHttpPostData(data: [
            "user": UserDefaults.standard.string(forKey: "user")!,
            "name": self.name.text!,
            "price": self.price.text!,
            "amount": self.amount.text!,
            "restaurantName": self.restaurantName,
            "restaurantId": self.restaurantId
        ])
        guard let url = URL(string: "http://localhost:8080/WebApp/addToCart") else {return}
        var req = URLRequest(url: url)
        req.httpMethod = "post"
        req.httpBody = param.data(using: .utf8)
        
        let session = URLSession.shared
        session.dataTask(with: req){ (data, res, err) in
            if let data = data{
                do{
                    let result = try JSONDecoder().decode(APIResult.self, from: data)
                    DispatchQueue.main.async {
                        if result.status{
                            self.tools.addingNotification(message: "added sucessfully!")
                            self.amount.text = "1"
                        }
                        else{
                            self.tools.addingNotification(message: "adding failed!")
                        }
                    }
                }catch{
                    print(error)
                }
            }
        }.resume()
    }
    
    override func awakeFromNib() {
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
}
