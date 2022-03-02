//
//  AccountViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/8/9.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit
import SafariServices

class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profile: UIImageView!{
        didSet{
            profile.layer.cornerRadius = 60
            profile.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var InternetBtn: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var detailTableView: UITableView!
    var userInfo: [[String]] = []
    let header = ["Credit Cards", "Address"]
    let tools = Tools()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapProfile = UITapGestureRecognizer(target: self, action: #selector(changeProfile))
        profile.addGestureRecognizer(tapProfile)
        profile.isUserInteractionEnabled = true
        detailTableView.delegate = self
        detailTableView.dataSource = self
    }
    
    @IBAction func toInternet(_ sender: Any) {
        if let url = URL(string: "http://www.ibest1.com"){
            let safariController = SFSafariViewController(url:url);
            safariController.modalPresentationStyle = .fullScreen;
            present(safariController, animated: true, completion: nil);
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.present(tools.loadingView(type: "loading"), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getUserInfo()
        getImage()
    }
    
    @IBAction func toNewRestaurant(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newRestaurantView = storyboard.instantiateViewController(identifier: "NewRestaurantNavigator")
        newRestaurantView.modalPresentationStyle = .fullScreen
        present(newRestaurantView, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profile.image = selectedImage
            profile.contentMode = .scaleAspectFill
            profile.clipsToBounds = true
            sendImage(image: selectedImage.jpegData(compressionQuality: 1)!)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func changeProfile(){
        let photoSourceRequestController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default, handler:{
            (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        photoSourceRequestController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // for ipad:
        
        if let popoverController = photoSourceRequestController.popoverPresentationController{
            popoverController.sourceView = profile
            popoverController.sourceRect = profile.bounds
        }
        
        present(photoSourceRequestController, animated: true, completion: nil)
    }
    
    func sendImage(image: Data){
        let param = tools.toHttpPostData(data: [
            "user": UserDefaults.standard.string(forKey: "user")!,
            "data": image.base64EncodedString().replacingOccurrences(of: "+", with: "%2B")
        ])
        guard let url = URL(string: "http://localhost:8080/WebApp/sendProfile") else{return}
        var req = URLRequest(url: url)
        req.httpMethod = "post"
        req.httpBody = param.data(using: .utf8)
        
        let session = URLSession.shared
        session.dataTask(with: req){ (data, res, err) in
            if let data = data{
                do{
                    let result = try JSONDecoder().decode(APIResult.self, from: data)
                    if result.status{
                        
                    }
                }catch{
                    print(error)
                }
            }
        }.resume()
    }
    
    @objc func dismissLoadingView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func getImage(){
        let param = tools.toHttpPostData(data: [
            "user": UserDefaults.standard.string(forKey: "user")!
        ])
        guard let url = URL(string: "http://localhost:8080/WebApp/getProfile") else {return}
        var req = URLRequest(url: url)
        req.httpMethod = "post"
        req.httpBody = param.data(using: .utf8)
        let session = URLSession.shared
        session.dataTask(with: req){ (data, res, err) in
            if let data = data{
                do{
                    let result = try JSONDecoder().decode(profileData.self, from: data)
                    if result.status{
                        DispatchQueue.main.async {
                            let imageData = Data.init(base64Encoded: result.profile.replacingOccurrences(of: "%2B", with: "+"), options: .init(rawValue: 0))
                            let image = UIImage(data: imageData!)
                            self.profile.image = image
                            self.profile.contentMode = .scaleAspectFill
                            self.profile.clipsToBounds = true
                            
                            _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.dismissLoadingView), userInfo: nil, repeats: false)
                        }
                    }
                }catch{
                    print(error)
                }
            }
        }.resume()
    }
    
    func getUserInfo(){
        userInfo = []
        let param = tools.toHttpPostData(data: ["user": UserDefaults.standard.string(forKey: "user")!])
        guard let url = URL(string: "http://localhost:8080/WebApp/getUserInfo") else{return}
        
        var req = URLRequest(url: url)
        req.httpMethod = "post"
        req.httpBody = param.data(using: .utf8)
        let session = URLSession.shared
        session.dataTask(with: req){(data, req, err) in
            if let data = data{
                do{
                    let result = try JSONDecoder().decode(UserInfo.self, from: data)
                    if result.status{
                        self.userInfo.append([])
                        for card in result.cards{
                            if !(self.userInfo[0].contains(card)){
                                self.userInfo[0].append(card)
                            }
                        }
                        
                        self.userInfo.append([])
                        for address in result.addresses{
                            if !(self.userInfo[1].contains(address)){
                                self.userInfo[1].append(address)
                            }
                        }
                        DispatchQueue.main.async {
                            self.name.text = result.name
                            self.number.text = result.number
                            self.detailTableView.reloadData()
                        }
                    }
                    else{
                        print("error while getting user information")
                    }
                }catch{
                    print(error)
                }
            }
        }.resume()
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return userInfo.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfo[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = userInfo[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = .white
        cell.layer.backgroundColor = tools.getRGB(r: 49, g: 49, b: 49)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = tableView.frame
        let view = UIView()
        
        let headerTitle: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        headerTitle.text = header[section]
        headerTitle.textColor = .white
        
        let addCardBtn: UIButton = UIButton(frame: CGRect(x: frame.size.width-160, y: 0, width: 160, height: 40))
        addCardBtn.setTitle("add credit card", for: .normal)
        addCardBtn.titleLabel?.font = addCardBtn.titleLabel?.font.withSize(12)
        addCardBtn.setTitleColor(.orange, for: .normal)
        addCardBtn.addTarget(self, action: #selector(addNewCard), for: .touchUpInside)
        
        let addAddressBtn: UIButton = UIButton(frame: CGRect(x: frame.size.width-160, y: 0, width: 160, height: 40))
        addAddressBtn.setTitle("add address", for: .normal)
        addAddressBtn.titleLabel?.font = addAddressBtn.titleLabel?.font.withSize(12)
        addAddressBtn.setTitleColor(.orange, for: .normal)
        addAddressBtn.addTarget(self, action: #selector(addNewAddress), for: .touchUpInside)
        
        let subViews = [addCardBtn, addAddressBtn]
        
        view.addSubview(headerTitle)
        view.addSubview(subViews[section])
        
        return view
    }
    
    @objc func addNewCard(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "NewCardNavigator")
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func addNewAddress(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "NewAddressNavigator")
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
}

extension String {
    var urlQueryValueEscaped: String {
        let urlQueryValueAllowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "+&="))
        return self.addingPercentEncoding(withAllowedCharacters: urlQueryValueAllowed)!
            .replacingOccurrences(of: " ", with: "+")
    }
}
