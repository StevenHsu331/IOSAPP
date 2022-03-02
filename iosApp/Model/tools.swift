//
//  tools.swift
//  iosApp
//
//  Created by 許景評 on 2021/8/2.
//  Copyright © 2021 許景評. All rights reserved.
//

import Foundation
import UIKit

class Tools {
    func getRGB(r: CGFloat, g: CGFloat, b: CGFloat) -> CGColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1).cgColor
    }
    
    func getRGB(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> CGColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a).cgColor
    }
    
    func toHttpPostData(data: Dictionary<String, String>)-> String{
        var result = ""
        var resultSet: [String] = []
        
        for o in data{
            resultSet.append(o.key + "=" + o.value)
        }
        result = resultSet.joined(separator: "&")
        
        return result
    }
    
    func addquotes(string: String)-> String{
        var result = "\""
        result += string
        result += "\""
        return result
    }
    
    func addSingleQuotes(string: String)-> String{
        var result = "\'"
        result += string
        result += "\'"
        return result
    }
    
    func wrap(string: String, first: String, end: String)-> String{
        var result = first
        result += string
        result += end
        return result
    }
    
    func toJSONString(data: Dictionary<String, String>)-> String{
        var result = "{"
        var resultSet: [String] = []
        for o in data{
            resultSet.append(addquotes(string: o.key) + ":" + addquotes(string: o.value))
        }
        result += resultSet.joined(separator: ",")
        result += "}"
        return result
    }
    
    func toJSONString(data: Dictionary<String, String>, arrayAt: [String])-> String{
        var result = "{"
        var resultSet: [String] = []
        for o in data{
            if arrayAt.contains(o.key){
                resultSet.append(addquotes(string: o.key) + ":" + wrap(string: o.value, first: "[", end: "]"))
            }
            else{
                resultSet.append(addquotes(string: o.key) + ":" + addquotes(string: o.value))
            }
        }
        result += resultSet.joined(separator: ",")
        result += "}"
        return result
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController

        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }

        return topMostViewController
    }
    
    func addingNotification(message: String) {
        let notification = UIAlertController(title: "System notification", message: message, preferredStyle: .alert)
        
        notification.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in
            print("tapped Dismiss")
        }))
        
        self.getTopMostViewController()?.present(notification, animated: true)
    }
    
    func addingNotification(message: String, vc: UIViewController) {
        let notification = UIAlertController(title: "System notification", message: message, preferredStyle: .alert)
        
        notification.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in
            print("tapped Dismiss")
        }))
        
        vc.present(notification, animated: true)
    }
    
    func addingNotification(message: String, completion: @escaping ()-> Void) {
        let notification = UIAlertController(title: "System notification", message: message, preferredStyle: .alert)
        
        notification.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in
            completion()
        }))
        
        self.getTopMostViewController()?.present(notification, animated: true)
    }
    
    func loadingView(type: String)-> AnimationViewController{
        let AnimationController = AnimationViewController()
        AnimationController.modalPresentationStyle = .overCurrentContext
        AnimationController.modalTransitionStyle = .crossDissolve
        AnimationController.type = type
        
        return AnimationController
    }
    
    // set transition to right to left
//    func setTransitionStyle(){
//        let transition = CATransition()
//        transition.duration = 0.25
//        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        transition.type = CATransitionType.push
//        transition.subtype = CATransitionSubtype.fromRight
//        self.view.window!.layer.add(transition, forKey: nil)
//    }
}
