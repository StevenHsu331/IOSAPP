//
//  MapStackView.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/13.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit
import MapKit

class MapStackView: UIStackView, MKMapViewDelegate{
    @IBOutlet var addressMapView: MKMapView!
    
    let tools = Tools()
    
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentFullMap))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
        addressMapView.delegate = self
        addressMapView.showsUserLocation = true
    }
    
    @objc func presentFullMap(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "FullMapNavigator")
        
        controller.modalPresentationStyle = .fullScreen
        if let currentView = tools.getTopMostViewController(){
            currentView.present(controller, animated: true, completion: nil)
        }
    }
}
