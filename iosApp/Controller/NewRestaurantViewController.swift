//
//  NewRestaurantViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/12.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit
import MapKit

class NewRestaurantViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var name: UITextField!{
        didSet{
            name.delegate = self
            name.tag = 1
            name.becomeFirstResponder()
        }
    }
    @IBOutlet weak var introduction: UITextView!{
        didSet{
            introduction.tag = 2
        }
    }
    @IBOutlet weak var address: UITextField!{
        didSet{
            address.delegate = self
            address.tag = 3
        }
    }
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var errorMsg: UILabel!
    let tools = Tools()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapToEndEditing = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapToEndEditing.cancelsTouchesInView = false
        view.addGestureRecognizer(tapToEndEditing)
        
        let tapToFullMap = UITapGestureRecognizer(target: self, action: #selector(openMap))
        mapView.addGestureRecognizer(tapToFullMap)
        mapView.isUserInteractionEnabled = true
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submit(_ sender: Any) {
        if verify(){
            errorMsg.alpha = 0
            
            let param = tools.toHttpPostData(data: [
                "user": UserDefaults.standard.string(forKey: "user")!,
                "name": name.text!,
                "introduction": introduction.text!,
                "address": address.text!
            ])
            guard let url = URL(string: "http://localhost:8080/WebApp/addNewRestaurant") else{return}
            var req = URLRequest(url: url)
            req.httpMethod = "post"
            req.httpBody = param.data(using: .utf8)
            let session = URLSession.shared
            session.dataTask(with: req){
                (data, res, err) in
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
                                self.tools.addingNotification(message: "some error occur while adding, please try again!")
                            }
                        }
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
        else{
            errorMsg.alpha = 1
        }
    }
    
    @objc func openMap(){
        let fullMap = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "FullMapNavigator")
        fullMap.modalPresentationStyle = .fullScreen
        present(fullMap, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1){
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func verify()-> Bool{
        var status: Bool = true
        
        if name.text == ""{
            status = false
            name.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            name.layer.borderWidth = 1
        }
        else{
            name.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            name.layer.borderWidth = 0.15
        }
        if introduction.text == ""{
            status = false
            introduction.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            introduction.layer.borderWidth = 1
        }
        else{
            introduction.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            introduction.layer.borderWidth = 0.15
        }
        if address.text == ""{
            status = false
            address.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            address.layer.borderWidth = 1
        }
        else{
            address.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            address.layer.borderWidth = 0.15
        }
        
        return status
    }
}
