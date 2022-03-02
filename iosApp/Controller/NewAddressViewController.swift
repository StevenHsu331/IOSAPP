//
//  NewAddressViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/12.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit
import MapKit

class NewAddressViewController: UIViewController {

    @IBOutlet weak var Address: UITextField!
    @IBOutlet weak var errorMsg: UILabel!
    let tools = Tools()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapToEndEditing = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapToEndEditing.cancelsTouchesInView = false
        view.addGestureRecognizer(tapToEndEditing)
    }
    
    @IBAction func sendValue(_ sender: Any) {
        if Address.text != ""{
            errorMsg.alpha = 0
            
            let param = tools.toHttpPostData(data: ["user": UserDefaults.standard.string(forKey: "user")!, "address": Address.text!])
            guard let url = URL(string: "http://localhost:8080/WebApp/addNewAddress") else {return}
            var req = URLRequest(url: url)
            req.httpMethod = "post"
            req.httpBody = param.data(using: .utf8)
            
            let session = URLSession.shared
            session.dataTask(with: req){(data, res, err) in
                if let data = data{
                    do{
                        let result = try JSONDecoder().decode(APIResult.self, from: data)
                        if result.status{
                            DispatchQueue.main.async {
                                self.tools.addingNotification(message: "adding successful!", vc: self)
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                self.tools.addingNotification(message: "adding failed!", vc: self)
                            }
                        }
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
        else{
            errorMsg.text = "Address Can't be empty!"
            errorMsg.alpha = 1
        }
    }
    
    @IBAction func backToAccount(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
}
