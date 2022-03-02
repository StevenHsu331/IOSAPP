//
//  CartTableViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/8/7.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class CartTableViewController: UITableViewController {
    
    var cart: Dictionary<String, [[String]]> = [:]
    var cartOrder: [String] = []
    var viewWidth: CGFloat = 0.0;
    var checkOutBtn = UIButton()
    var toRestaurantsBtn = UIButton()
    var notificationLabel = UILabel()
    let tools = Tools()
    enum Section{
        case all
    }
    
    @IBOutlet var cartTableView: UITableView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        viewWidth = self.view.frame.width
        
        self.notificationLabel = UILabel()
        self.notificationLabel.text = "Nothing in your cart!"
        self.notificationLabel.textColor = .white
        self.notificationLabel.textAlignment = .center
        self.navigationController?.view.addSubview(notificationLabel)
        
        self.toRestaurantsBtn = UIButton(type: .custom)
        self.toRestaurantsBtn.setTitleColor(UIColor.white, for: .normal)
        self.toRestaurantsBtn.setTitle("Go Get Some Food", for: .normal)
        self.toRestaurantsBtn.addTarget(self, action: #selector(toRestaurants), for: UIControl.Event.touchUpInside)
        self.navigationController?.view.addSubview(toRestaurantsBtn)
        
        self.checkOutBtn = UIButton(type: .custom)
        self.checkOutBtn.setTitleColor(UIColor.white, for: .normal)
        self.checkOutBtn.setTitle("check out", for: .normal)
        self.checkOutBtn.addTarget(self, action: #selector(toFinalPurchase(_:)), for: UIControl.Event.touchUpInside)
        self.navigationController?.view.addSubview(checkOutBtn)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.present(tools.loadingView(type: "loading"), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.checkOutBtn.alpha = 0
        self.toRestaurantsBtn.alpha = 0
        self.notificationLabel.alpha = 0
        getCartList()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        toRestaurantsBtn.backgroundColor = UIColor.orange
        toRestaurantsBtn.clipsToBounds = true
        toRestaurantsBtn.center = self.tableView.center
        toRestaurantsBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toRestaurantsBtn.widthAnchor.constraint(equalToConstant: 240),
            toRestaurantsBtn.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        notificationLabel.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 1)
        notificationLabel.clipsToBounds = true
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notificationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            notificationLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
            notificationLabel.widthAnchor.constraint(equalToConstant: 240),
            notificationLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        checkOutBtn.layer.cornerRadius = 20
        checkOutBtn.backgroundColor = UIColor.orange
        checkOutBtn.clipsToBounds = true
        checkOutBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkOutBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            checkOutBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
            checkOutBtn.widthAnchor.constraint(equalToConstant: 240),
            checkOutBtn.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func toRestaurants(){
        self.navigationController?.tabBarController?.selectedIndex = 0
    }

    @IBAction func toFinalPurchase(_ sender: UIButton){
        let sendOrderView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SendOrderNavigator") as! UINavigationController
        sendOrderView.modalPresentationStyle = .fullScreen
        let controller = sendOrderView.viewControllers.first as? SendOrderViewController
        
        for i in 0..<cartOrder.count{
            controller?.cart[cartOrder[i]] = []
            controller?.priceValues.append(0)
            
            for value in cart[cartOrder[i]]!{
                controller?.cart[cartOrder[i]]!.append(value)
                controller?.priceValues[i] += (Int(value[1])! * (Int(value[2])!))
            }
        }
        for order in self.cartOrder{
            controller?.cartOrder.append(order)
        }
        present(sendOrderView, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return cart.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.layer.backgroundColor = tools.getRGB(r: 49, g: 49, b: 49)
        
        let headerTitle: UILabel = UILabel(frame: CGRect(x: 20, y: 5, width: 160, height: 40))
        headerTitle.text = cartOrder[section].components(separatedBy: " ")[1]
        headerTitle.textColor = .white
        headerTitle.font = headerTitle.font.withSize(22)
        view.addSubview(headerTitle)
        
        return view
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart[cartOrder[section]]?.count ?? 0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "product", for: indexPath) as! ProductCellInCart
        cell.name.text = cart[cartOrder[indexPath.section]]?[indexPath.row][0]
        cell.price.text = cart[cartOrder[indexPath.section]]?[indexPath.row][1]
        cell.amount.text = cart[cartOrder[indexPath.section]]?[indexPath.row][2]
        cell.layer.backgroundColor = tools.getRGB(r: 49, g: 49, b: 49)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "EDIT"){
            [weak self] (action, view, completionHandler) in self?.editHandler(indexPath: indexPath)
            completionHandler(true)
        }
        edit.backgroundColor = .systemGreen
        
        let delete = UIContextualAction(style: .normal, title: "DELETE"){
            [weak self] (action, view, completionHandler) in self?.deleteHandler(indexPath: indexPath)
            completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [edit, delete])

        return configuration
    }
    
    func editHandler(indexPath: IndexPath){
        
    }
    
    func deleteHandler(indexPath: IndexPath){
        guard let url = URL(string: "http://localhost:8080/WebApp/deleteFromCart") else{return}
        let postData = tools.toHttpPostData(data: [
            "user": UserDefaults.standard.object(forKey: "user") as! String,
            "name": cart[cartOrder[indexPath.section]]![indexPath.row][0]
        ])
        var req = URLRequest(url: url)
        req.httpMethod = "post"
        req.httpBody = postData.data(using: .utf8)
        
        let session = URLSession.shared
        session.dataTask(with: req){(data, res, err) in
            if let data = data{
                do{
                    let result = try JSONDecoder().decode(APIResult.self, from: data)
                    if result.status{
                        self.cart[self.cartOrder[indexPath.section]]!.remove(at: indexPath.row)
                        if self.cart[self.cartOrder[indexPath.section]]?.count == 0{
                            self.cart.removeValue(forKey: self.cartOrder[indexPath.section])
                            self.cartOrder.remove(at: indexPath.section)
                        }
                        
                        DispatchQueue.main.async {
                            self.cartTableView.reloadData()
                            if self.cart.count == 0{
                                self.checkOutBtn.alpha = 0
                                self.toRestaurantsBtn.alpha = 1
                                self.notificationLabel.alpha = 1
                            }
                        }
                    }
                    else{
                        print("error occur while deleting from cart")
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
    
    func getCartList(){
        cart = [:]
        cartOrder = []
        
        guard let url = URL(string: "http://localhost:8080/WebApp/getCartList") else{return}
        let postData = UserName(user: UserDefaults.standard.object(forKey: "user") as! String)
        var req = URLRequest(url: url)
        req.httpMethod = "post"
        req.addValue("application/json", forHTTPHeaderField: "content-type")
        req.httpBody = try? JSONEncoder().encode(postData)
        
        let session = URLSession.shared
        session.dataTask(with: req){(data, res, err) in
            if let data = data{
                do{
                    let result = try JSONDecoder().decode(CartList.self, from: data)
                    if result.status{
                        DispatchQueue.main.async {
                            if result.products.count == 0{
                                self.checkOutBtn.alpha = 0
                                self.toRestaurantsBtn.alpha = 1
                                self.notificationLabel.alpha = 1
                            }
                            else{
                                self.checkOutBtn.alpha = 1
                                self.toRestaurantsBtn.alpha = 0
                                self.notificationLabel.alpha = 0
                            }
                            
                            for product in result.products{
                                if(!self.cartOrder.contains(product.restaurantId + " " + product.restaurantName)){
                                    self.cart[product.restaurantId + " " + product.restaurantName] = []
                                    self.cartOrder.append(product.restaurantId + " " + product.restaurantName)
                                }
                                
                                self.cart[product.restaurantId + " " + product.restaurantName]!.append([
                                    product.name,
                                    product.price,
                                    product.amount,
                                ])
                            }
                            self.cartTableView.reloadData()
                            _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.dismissLoadingView), userInfo: nil, repeats: false)
                        }
                    }
                    else{
                        print("connection failed while getting cart list")
                    }
                }catch{
                    print(error)
                }
            }
        }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cartToProduct"{
            self.checkOutBtn.alpha = 0
            if let indexPath = tableView.indexPathForSelectedRow{
                let destinationController = segue.destination as! ProductViewController
                destinationController.editingCell = indexPath
            destinationController.productInfo.append(self.cart[cartOrder[indexPath.section]]![indexPath.row][0])
            destinationController.productInfo.append(self.cart[cartOrder[indexPath.section]]![indexPath.row][1])
            destinationController.productInfo.append(self.cart[cartOrder[indexPath.section]]![indexPath.row][2])
                
                let restaurantInfo = cartOrder[indexPath.section].components(separatedBy: " ")
                destinationController.productInfo.append(restaurantInfo[0])
                destinationController.productInfo.append(restaurantInfo[1])
            }
        }
    }
    
    @IBAction func unwindToThisView(sender: UIStoryboardSegue) {
        self.checkOutBtn.alpha = 1
    }
}
