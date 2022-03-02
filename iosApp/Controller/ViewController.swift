//
//  ViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/7/29.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        loginBtn.layer.cornerRadius = 20;
        signUpBtn.layer.cornerRadius = 20;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkStatus()
    }
    
    func checkStatus(){
        if UserDefaults.standard.bool(forKey: "isLogined") && UserDefaults.standard.object(forKey: "user") != nil{
            let MainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController")
            MainView.modalPresentationStyle = .fullScreen
            self.present(MainView, animated: true, completion: nil)
        }
    }
}

