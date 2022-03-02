//
//  MainViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/8/9.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    let tools = Tools()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appearance = navigationController?.navigationBar.standardAppearance{
            appearance.configureWithTransparentBackground()
            
            if let customFont = UIFont(name: "Nunito-Bold", size: 45){
                appearance.titleTextAttributes = [.foregroundColor: tools.getRGB(r: 218, g: 96, b: 51)]
                appearance.largeTitleTextAttributes = [.foregroundColor: tools.getRGB(r: 218, g: 96, b: 51), .font: customFont]
            }
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}
