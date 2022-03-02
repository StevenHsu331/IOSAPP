//
//  AnimationViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/10/8.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit
import Lottie

class AnimationViewController: UIViewController {
    
    var type: String = ""
    var animationView: AnimationView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch type {
        case "loading":
            animationView = AnimationView(name: "lf30_editor_uluz72ts")
        case "success":
            animationView = AnimationView(name: "1127-success")
        default:
            print("wrong parameter!")
        }
        
        animationView?.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
        animationView?.center = self.view.center
        animationView?.loopMode = .loop
        animationView?.contentMode = .scaleAspectFill
        
        view.addSubview(animationView!)

        animationView?.play()
    }
    
    func dismissLoading(){
        self.animationView!.pause()
        self.dismiss(animated: true, completion: nil)
    }
}
