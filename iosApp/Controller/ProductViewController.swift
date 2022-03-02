//
//  ProductViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/15.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController {

    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productAmount: UILabel!
    @IBOutlet weak var amountStepper: UIStepper!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    let tools = Tools()
    var didChange: Bool = false
    var editingCell: IndexPath = IndexPath.init()
    var productInfo: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productName.text = productInfo[0]
        productPrice.text = productInfo[1]
        productAmount.text = productInfo[2]
        amountStepper.tintColor = .white
        amountStepper.minimumValue = 0
        amountStepper.maximumValue = 20
        amountStepper.value = Double(productInfo[2]) ?? 0
        amountStepper.stepValue = 1
        amountStepper.autorepeat = true
        amountStepper.wraps = true
    }
    
    @IBAction func saveToCart(_ sender: Any) {
        if didChange{
            let param = tools.toHttpPostData(data: [
                "user": UserDefaults.standard.string(forKey: "user")!,
                "name": productName.text!,
                "price": productPrice.text!,
                "amount": productAmount.text!,
                "restaurantId": productInfo[3],
                "restaurantName": productInfo[4]
            ])
            
            guard let url = URL(string: "http://localhost:8080/WebApp/editProduct") else {return}
            var req = URLRequest(url: url)
            req.httpMethod = "post"
            req.httpBody = param.data(using: .utf8)
            
            let session = URLSession.shared
            session.dataTask(with: req){ (data, res, err) in
                if let data = data{
                    do{
                        let result = try JSONDecoder().decode(APIResult.self, from: data)
                        if result.status{
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "backToCart", sender: self)
                            }
                        }
                        else{
                            self.tools.addingNotification(message: "some error occur while editing, please try again")
                        }
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    @IBAction func addAmount(_ sender: Any) {
        productAmount.text = String(Int(amountStepper.value))
        didChange = true
    }
    
    func setTransitionStyle(){
        let transition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: nil)
    }
}
