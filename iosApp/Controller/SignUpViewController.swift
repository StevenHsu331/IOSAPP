//
//  SignUpViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/7/30.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var name: UITextField!{
        didSet{
            name.delegate = self
            name.tag = 1
            name.becomeFirstResponder()
        }
    }
    @IBOutlet weak var account: UITextField!{
        didSet{
            account.delegate = self
            account.tag = 2
        }
    }
    @IBOutlet weak var password: UITextField!{
        didSet{
            password.delegate = self
            password.tag = 3
        }
    }
    @IBOutlet weak var passwordCheck: UITextField!{
        didSet{
            passwordCheck.delegate = self
            passwordCheck.tag = 4
        }
    }
    @IBOutlet weak var number: UITextField!{
        didSet{
            number.delegate = self
            number.tag = 5
        }
    }
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var errorMsg: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    let tools = Tools()
    
    var data = ["","male", "female"];
    var genderPicker = UIPickerView()
    //let db = SQLiteHandler();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.hideKeyboard();
        
        name.layer.cornerRadius = 20
        name.layer.borderWidth = 1
        name.layer.borderColor = tools.getRGB(r: 131, g: 255, b: 230)
        account.layer.cornerRadius = 20
        account.layer.borderWidth = 1
        account.layer.borderColor = tools.getRGB(r: 131, g: 255, b: 230)
        password.layer.cornerRadius = 20
        password.layer.borderWidth = 1
        password.layer.borderColor = tools.getRGB(r: 131, g: 255, b: 230)
        passwordCheck.layer.cornerRadius = 20
        passwordCheck.layer.borderWidth = 1
        passwordCheck.layer.borderColor = tools.getRGB(r: 131, g: 255, b: 230)
        number.layer.cornerRadius = 20
        number.layer.borderWidth = 1
        number.layer.borderColor = tools.getRGB(r: 131, g: 255, b: 230)
        gender.layer.cornerRadius = 20
        gender.layer.borderWidth = 1
        gender.layer.borderColor = tools.getRGB(r: 131, g: 255, b: 230)
        submitBtn.layer.cornerRadius = 20
        submitBtn.layer.borderWidth = 1
        submitBtn.layer.borderColor = tools.getRGB(r: 131, g: 255, b: 230)
        gender.inputView = genderPicker;
        genderPicker.dataSource = self;
        genderPicker.delegate = self;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1){
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    @IBAction func sendValues(_ sender: Any) {
        if verification(){
            errorMsg.alpha = 0;
            
            let signUpData = SignUpData(name: name.text ?? "", account: account.text ?? "", password: password.text ?? "", number: number.text ?? "", gender: gender.text ?? "")
            
            guard let url = URL(string: "http://localhost:8080/WebApp/registerIOS") else {return}
            var req = URLRequest(url: url)
            req.httpMethod = "post"
            req.addValue("application/json", forHTTPHeaderField: "content-type")
            req.httpBody = try? JSONEncoder().encode(signUpData)
            
            let session = URLSession.shared
            session.dataTask(with: req){(data, res, err) in
                if let data = data{
                    do{
                        let result = try JSONDecoder().decode(SignUpResult.self, from: data)
                        if result.status{
                            DispatchQueue.main.async {
                                self.account.layer.borderColor = self.tools.getRGB(r: 131, g: 255, b: 230)
                                self.password.layer.borderColor = self.tools.getRGB(r: 131, g: 255, b: 230)
                                self.number.layer.borderColor = self.tools.getRGB(r: 131, g: 255, b: 230)
                                
                                let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController")
                                
                                if let navigator = self.navigationController{
                                    navigator.pushViewController(loginView, animated: true)
                                }
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                if !result.account{
                                    self.account.layer.borderColor = UIColor.red.cgColor;
                                }
                                if !result.password{
                                    self.password.layer.borderColor = UIColor.red.cgColor;
                                }
                                if !result.number{
                                    self.number.layer.borderColor = UIColor.red.cgColor;
                                }
                                self.errorMsg.text = "Values have been used"
                                self.errorMsg.alpha = 1;
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
            errorMsg.alpha = 1;
        }
    }
    
    func verification() -> Bool {
        var result: Bool = true;
        
        if name.text == ""{
            result = false
            name.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            name.layer.borderWidth = 1
        }
        else{
            name.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            name.layer.borderWidth = 0.15
        }
        if account.text?.count ?? 0 < 8{
            result = false
            account.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            account.layer.borderWidth = 1
        }
        else{
            account.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            account.layer.borderWidth = 0.15
        }
        if password.text?.count ?? 0 < 8 || password.text != passwordCheck.text{
            result = false
            password.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            passwordCheck.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            password.layer.borderWidth = 1
            passwordCheck.layer.borderWidth = 1
        }
        else{
            password.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            passwordCheck.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            password.layer.borderWidth = 0.15
            passwordCheck.layer.borderWidth = 0.15
        }
        if number.text?.count ?? 0 != 10{
            result = false
            number.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            number.layer.borderWidth = 1
        }
        else{
            number.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            number.layer.borderWidth = 0.15
        }
        if gender.text == ""{
            result = false
            gender.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            gender.layer.borderWidth = 1
        }
        else{
            gender.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            gender.layer.borderWidth = 0.15
        }
        
        return result;
    }
}

extension SignUpViewController{
    func hideKeyboard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap);
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true);
    }
}

extension SignUpViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count;
    }
}

extension SignUpViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row];
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gender.text = data[row];
        gender.resignFirstResponder();
    }
}
