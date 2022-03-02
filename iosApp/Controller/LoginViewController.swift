//
//  LoginViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/7/29.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ac: UITextField!{
        didSet{
            ac.becomeFirstResponder()
            ac.tag = 1
            ac.delegate = self
        }
    }
    @IBOutlet weak var pwd: UITextField!{
        didSet{
            pwd.tag = 2
            pwd.delegate = self
        }
    }
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var errorMSG: UILabel!
    let tools = Tools()
    
    let db = SQLiteHandler();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapToEndEditing = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapToEndEditing.cancelsTouchesInView = false
        view.addGestureRecognizer(tapToEndEditing)
        
        errorMSG.alpha = 0
        ac.layer.cornerRadius = 20
        ac.layer.borderWidth = 1
        ac.layer.borderColor = tools.getRGB(r: 131, g: 255, b: 230)
        pwd.layer.cornerRadius = 20
        pwd.layer.borderWidth = 1
        pwd.layer.borderColor = tools.getRGB(r: 131, g: 255, b: 230)
        submitBtn.layer.cornerRadius = 20
        submitBtn.layer.borderWidth = 1
        submitBtn.layer.borderColor = tools.getRGB(r: 131, g: 255, b: 230)
    }
    
    @IBAction func submit(_ sender: Any) {
        
        if verify(){
            errorMSG.alpha = 0
            
            let param = tools.toHttpPostData(data: [
                "account": ac.text ?? "",
                "password": pwd.text ?? ""
            ]);
            
            guard let url = URL(string: "http://localhost:8080/WebApp/login") else{ return }
            var req = URLRequest(url: url)
            req.httpMethod = "post"
            req.httpBody = param.data(using: .utf8)
            
            let session = URLSession.shared
            session.dataTask(with: req){ (data, res, err) in
                if let data = data{
                    do{
                        let result = try JSONDecoder().decode(LoginResult.self, from: data)
                        if result.status{
                            
                            // doing some UI controll must be in this block while making dataTsak
                            DispatchQueue.main.async{
                                UserDefaults.standard.set(self.ac.text, forKey: "user")
                                UserDefaults.standard.set(true, forKey: "isLogined")
                                UserDefaults.standard.synchronize()
                                
                                self.errorMSG.alpha = 0
                                self.errorMSG.text = ""
                                
                                let MainController = UIStoryboard(name: "Main", bundle: nil)
                                    .instantiateViewController(withIdentifier: "MainViewController")
                                MainController.modalPresentationStyle = .fullScreen
                                self.present(MainController, animated: true, completion: nil)
                            }
                        }
                        else{
                            // to do some UI controll while doing dataTsak requires to add this line
                            DispatchQueue.main.async {
                                if !result.account{
                                    self.errorMSG.text = "account doesn't exist"
                                }
                                else{
                                    self.errorMSG.text = "wrong password"
                                }
                                self.errorMSG.alpha = 1
                            }
                        }
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
        else{
            errorMSG.text = "Wrong Values!"
            errorMSG.alpha = 1
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1){
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func verify() -> Bool{
        var status = true
        
        if ac.text?.count ?? 0 < 8{
            status = false
            ac.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            ac.layer.borderWidth = 1
        }
        else{
            ac.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            ac.layer.borderWidth = 0.15
        }
        if pwd.text?.count ?? 0 < 8{
            status = false
            pwd.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            pwd.layer.borderWidth = 1
        }
        else{
            pwd.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            pwd.layer.borderWidth = 0.15
        }
        
        return status
    }
}
