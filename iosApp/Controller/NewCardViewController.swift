//
//  NewCardViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/12.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class NewCardViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var Code: UITextField!{
        didSet{
            Code.delegate = self
            Code.tag = 1
            Code.becomeFirstResponder()
        }
    }
    @IBOutlet weak var SafetyCode: UITextField!{
        didSet{
            SafetyCode.delegate = self
            SafetyCode.tag = 2
        }
    }
    @IBOutlet weak var ExpireDate: UITextField!{
        didSet{
            ExpireDate.delegate = self
            ExpireDate.tag = 3
        }
    }
    @IBOutlet weak var errorMsg: UILabel!
    
    let tools = Tools()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapToEndEditing = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapToEndEditing.cancelsTouchesInView = false
        view.addGestureRecognizer(tapToEndEditing)
    }
    
    @IBAction func sendValue(_ sender: Any) {
        if verify(){
            errorMsg.alpha = 0
            
            let param = tools.toHttpPostData(data: [
                "user": UserDefaults.standard.string(forKey: "user")!,
                "code": Code.text!,
                "safetyCode": SafetyCode.text!,
                "expireDate": ExpireDate.text!
            ])
            guard let url = URL(string: "http://localhost:8080/WebApp/addNewCard") else{return}
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
                                self.tools.addingNotification(message: "adding successful!")
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                self.tools.addingNotification(message: "adding failed!")
                            }
                        }
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
        else{
            errorMsg.text = "Wrong Values!"
            errorMsg.alpha = 1
        }
    }
    
    @IBAction func backToAccount(segue: UIStoryboardSegue) {
            dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1){
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func verify()-> Bool{
        var status = true
        
        if Code.text?.count != 16{
            status = false
            Code.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            Code.layer.borderWidth = 1
        }
        else{
            Code.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            Code.layer.borderWidth = 0.15
        }
        if SafetyCode.text?.count != 3{
            status = false
            SafetyCode.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            SafetyCode.layer.borderWidth = 1
        }
        else{
            SafetyCode.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            SafetyCode.layer.borderWidth = 0.15
        }
        if ExpireDate.text?.count != 4{
            status = false
            ExpireDate.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            ExpireDate.layer.borderWidth = 1
        }
        else{
            ExpireDate.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            ExpireDate.layer.borderWidth = 0.15
        }
        
        return status
    }
}
