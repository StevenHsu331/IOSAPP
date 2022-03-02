//
//  FullMapViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/13.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FullMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var FullMap: MKMapView!
    @IBOutlet weak var navigation: UINavigationItem!
    
    var locationManager = CLLocationManager()
    var didPutPin: Bool = false
    var currentAnnotation = MKPointAnnotation()
    var selectedAddress = ""
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(addPin))
        FullMap.delegate = self
        FullMap.addGestureRecognizer(tap)
        FullMap.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        configureLocationServices()
    }
    
    func centerMapOnUserLocation() {
//         simulator does not support estimating actual location
//        guard let coordinate = locationManager.location?.coordinate else {return}
        let home = CLLocationCoordinate2D(latitude: 24.99189, longitude: 121.53408)
        let coordinateRegion = MKCoordinateRegion(center: home, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        FullMap.setRegion(coordinateRegion, animated: true)
        self.locationManager.stopUpdatingLocation();
    }

    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerMapOnUserLocation()
    }
    
    @objc func addPin(gestureRecognizer: UITapGestureRecognizer){
        
        let location = gestureRecognizer.location(in: FullMap)
        let coordinate = FullMap.convert(location, toCoordinateFrom: FullMap)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        if didPutPin{
            FullMap.removeAnnotation(currentAnnotation)
        }
        else{
            didPutPin = true
        }
        FullMap.addAnnotation(annotation)
        currentAnnotation = annotation
        getAddress(coordinate: currentAnnotation.coordinate){ (address) in
            self.selectedAddress = address
        }
    }
    
    func getAddress(coordinate: CLLocationCoordinate2D, completion: @escaping (String)->()){
        var address = ""
        let location = CLGeocoder.init()
        location.reverseGeocodeLocation(CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (places, error) in
            if error == nil{
                if let place = places{
                    address += place[0].name ?? ""
                    address += ", "
                    address += place[0].locality ?? ""
                    address += ", "
                    address += place[0].country ?? ""
                    completion(address)
                }
            }
        }
    }
    
    @IBAction func dismiss(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveLocation(segue: UIStoryboardSegue) {
        if selectedAddress == ""{
//             simulator does not support estimating actual location
//            
//            guard let coordinate = locationManager.location?.coordinate else {return}
//            getAddress(coordinate: coordinate){
//                (address) in
//                self.selectedAddress = address
//            }
            
            getAddress(coordinate: CLLocationCoordinate2D(latitude: 24.99189, longitude: 121.53408)){
                (address) in
                self.selectedAddress = address
            }
        }
        if let navigator = presentingViewController as? UINavigationController{
            let presenter = navigator.viewControllers.first
            
            switch presenter?.restorationIdentifier {
            case "NewAddressViewController":
                if let presenter = presenter as? NewAddressViewController{
                    presenter.Address.text = selectedAddress
                }
            case "NewRestaurantViewController":
                if let presenter = presenter as? NewRestaurantViewController{
                    presenter.address.text = selectedAddress
                }
            case "SendOrderViewController":
                if let presenter = presenter as? SendOrderViewController{
                    presenter.addressSelector.text = selectedAddress
                }
            default:
                print("error while sending map value!")
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
