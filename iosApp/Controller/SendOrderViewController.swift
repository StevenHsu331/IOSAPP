//
//  SendOrderViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/15.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit
import DropDown

class SendOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var creditCardSelector: UITextField!
    @IBOutlet weak var addressSelector: UITextField!
    @IBOutlet weak var purchases: UITableView!
    @IBOutlet weak var errorMsg: UILabel!
    let tools = Tools()
    var addresses: [String] = []
    var creditCards: [String] = []
    var addressMenu: DropDown = DropDown()
    var creditCardsMenu: DropDown = DropDown()
    var dropDownMenu: DropDown = DropDown()
    var note: [UITextView] = []
    var tableData: [[String]] = [
        ["tableware", "0"],
        ["sauce", "0"],
        ["bag", "2"]
    ]
    var cart: Dictionary<String, [[String]]> = [:]
    var cartOrder: [String] = []
    var cartList: [[String]] = []
    var checkOutBtn = UIButton()
    var totalPrice = UILabel()
    var viewWidth: CGFloat = 0.0
    var priceValues: [Int] = []
    var totalPriceValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewWidth = self.view.frame.width
        
        self.purchases.separatorStyle = .singleLine
        self.purchases.separatorColor = .white
        
        let tapAddressSelector = UITapGestureRecognizer(target: self, action: #selector(didTapAddressSelector))
        self.addressSelector.addGestureRecognizer(tapAddressSelector)
        self.addressMenu.anchorView = addressSelector
        self.addressMenu.dataSource = addresses
        self.addressMenu.selectionAction = { (index, title) in
            if index != self.addresses.count - 1{
                self.addressSelector.text = title
            }
            else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let navigator = storyboard.instantiateViewController(identifier: "FullMapNavigator")
                navigator.modalPresentationStyle = .fullScreen
                self.present(navigator, animated: true)
            }
        }
        
        let tapCreditCardsSelector = UITapGestureRecognizer(target: self, action: #selector(didTapCreditCardsSelector))
        self.creditCardSelector.addGestureRecognizer(tapCreditCardsSelector)
        self.creditCardsMenu.anchorView = creditCardSelector
        self.creditCardsMenu.dataSource = creditCards
        self.creditCardsMenu.selectionAction = { (index, title) in
            if index != self.creditCards.count - 1{
                self.creditCardSelector.text = title
            }
            else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let navigator = storyboard.instantiateViewController(identifier: "NewCardNavigator")
                navigator.modalPresentationStyle = .fullScreen
                self.present(navigator, animated: true)
            }
        }
        
        self.checkOutBtn = UIButton(type: .custom)
        self.checkOutBtn.setTitleColor(UIColor.white, for: .normal)
        self.checkOutBtn.setTitle("check out", for: .normal)
        self.checkOutBtn.addTarget(self, action: #selector(checkOut(_:)), for: UIControl.Event.touchUpInside)
        
        for price in priceValues{
            self.totalPriceValue += price
        }
        self.totalPrice.textColor = .white
        self.totalPrice.textAlignment = NSTextAlignment.center
        self.totalPrice.text = "total cost: " + String(totalPriceValue)
        
        self.navigationController?.view.addSubview(checkOutBtn)
        self.navigationController?.view.addSubview(totalPrice)
        self.purchases.delegate = self
        self.purchases.dataSource = self
    }
    
    @objc func didTapAddressSelector(){
        getAddress()
    }
    
    @objc func didTapCreditCardsSelector(){
        getCreditCards()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        checkOutBtn.layer.cornerRadius = 20
        checkOutBtn.backgroundColor = UIColor.orange
        checkOutBtn.clipsToBounds = true
        checkOutBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkOutBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -(viewWidth/2 - 120)),
            checkOutBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
            checkOutBtn.widthAnchor.constraint(equalToConstant: 240),
            checkOutBtn.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        totalPrice.backgroundColor = UIColor.orange
        totalPrice.clipsToBounds = true
        totalPrice.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalPrice.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -(viewWidth/2 - 140)),
            totalPrice.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100),
            totalPrice.widthAnchor.constraint(equalToConstant: 280),
            totalPrice.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func dismissObjc(){
        self.dismiss(animated: true, completion: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func checkOut(_ sender: UIButton){
        
        if verify(){
            self.errorMsg.alpha = 0
            var orderInfo: Dictionary<String, String> = [:]
            getCheckBoxesValues()
            
            for i in 0..<cartOrder.count{
                var products: [String] = []
                for item in cart[cartOrder[i]]!{
                    products.append(tools.toJSONString(data: [
                        "name": item[0],
                        "price": item[1],
                        "amount": item[2]
                    ]))
                }
                
                orderInfo[cartOrder[i].components(separatedBy: " ")[0]] = tools.toJSONString(data: [
                    "restaurantName": cartOrder[i].components(separatedBy: " ")[1],
                    "user": UserDefaults.standard.string(forKey: "user")!,
                    "cost": String(self.priceValues[i]),
                    "note": self.note[i].text ?? "",
                    "address": self.addressSelector.text!,
                    "card": self.creditCardSelector.text!,
                    "products": products.joined(separator: ",")
                ], arrayAt: ["products"])
            }
            
            let param = tools.toHttpPostData(data: orderInfo)
            guard let url = URL(string: "http://localhost:8080/WebApp/sendOrder") else{return}
            var req = URLRequest(url: url)
            req.httpMethod = "post"
            req.httpBody = param.data(using: .utf8)
            let session = URLSession.shared
            session.dataTask(with: req){ (data, res, err) in
                if let data = data{
                    do{
                        let result = try JSONDecoder().decode(APIResult.self, from: data)
                        if result.status{
                            DispatchQueue.main.async {
                                self.present(self.tools.loadingView(type: "success"), animated: true)
                                
                                _ = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.dismissObjc), userInfo: nil, repeats: false)
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                self.tools.addingNotification(message: "sorry, some error occur while sending order, please try again.")
                            }
                        }
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
        else{
            self.errorMsg.alpha = 1
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.cart.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.tableData.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AdditionalPurchase
            cell.name.text = tableData[indexPath.row][0]
            cell.price.text = tableData[indexPath.row][1]
            cell.section = indexPath.section
            cell.layer.backgroundColor = tools.getRGB(r: 49, g: 49, b: 49)
            
            return cell
        }
        else{
            let cell = UITableViewCell()
            cell.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 1)
            
            let headerTitle = UILabel()
            headerTitle.translatesAutoresizingMaskIntoConstraints = false
            headerTitle.layer.backgroundColor = tools.getRGB(r: 49, g: 49, b: 49)
            headerTitle.textColor = .white
            headerTitle.text = "Note:"
            cell.addSubview(headerTitle)
            
            NSLayoutConstraint.activate([
                headerTitle.topAnchor.constraint(equalTo: cell.topAnchor, constant: 0),
                headerTitle.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -20),
                headerTitle.heightAnchor.constraint(equalToConstant: 40),
                headerTitle.widthAnchor.constraint(equalToConstant: viewWidth-40)
            ])
            
            self.note.append(UITextView())
            self.note[indexPath.section].translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(self.note[indexPath.section])

            NSLayoutConstraint.activate([
                self.note[indexPath.section].topAnchor.constraint(equalTo: cell.topAnchor, constant: 40),
                self.note[indexPath.section].trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -20),
                self.note[indexPath.section].heightAnchor.constraint(equalToConstant: 160),
                self.note[indexPath.section].widthAnchor.constraint(equalToConstant: viewWidth-40)
            ])
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.layer.backgroundColor = tools.getRGB(r: 49, g: 49, b: 49)
        
        let headerTitle: UILabel = UILabel(frame: CGRect(x: 20, y: 5, width: 160, height: 40))
        headerTitle.textColor = .white
        headerTitle.font = headerTitle.font.withSize(22)
        headerTitle.text = cartOrder[section].components(separatedBy: " ")[1]
        view.addSubview(headerTitle)
        
        let costLable: UILabel = UILabel(frame: CGRect(x: self.viewWidth-100, y: 5, width: 80, height: 40))
        costLable.textColor = .white
        view.addSubview(costLable)
        costLable.text = String(self.priceValues[section])
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.tableData.count {
            return 40
        }
        else{
            return 210
        }
    }
    
    func verify()-> Bool{
        var status = true
        if self.addressSelector.text == ""{
            self.addressSelector.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            self.addressSelector.layer.borderWidth = 1
            status = false
        }
        else{
            self.addressSelector.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            self.addressSelector.layer.borderWidth = 0.15
        }
        if self.creditCardSelector.text == ""{
            self.creditCardSelector.layer.borderColor = tools.getRGB(r: 255, g: 0, b: 0)
            self.creditCardSelector.layer.borderWidth = 1
            status = false
        }
        else{
            self.creditCardSelector.layer.borderColor = tools.getRGB(r: 49, g: 49, b: 49)
            self.creditCardSelector.layer.borderWidth = 0.15
        }
        
        
        return status
    }
    
    func getCreditCards(){
        self.creditCards = []
        
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
                        for card in result.cards{
                            if !(self.creditCards.contains(card)){
                                self.creditCards.append(card)
                            }
                        }
                        self.creditCards.append("new")
                        
                        DispatchQueue.main.async {
                            self.creditCardsMenu.dataSource = self.creditCards
                            self.creditCardsMenu.show()
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
    
    func getAddress(){
        self.addresses = []
        
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
                        
                        for address in result.addresses{
                            if !(self.addresses.contains(address)){
                                self.addresses.append(address)
                            }
                        }
                        self.addresses.append("new")
                        
                        DispatchQueue.main.async {
                            self.addressMenu.dataSource = self.addresses
                            self.addressMenu.show()
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
    
    func getCheckBoxesValues(){
        guard let cellsIndexPath = self.purchases.indexPathsForVisibleRows else {return}
        
        for indexPath in cellsIndexPath{
            if indexPath.row < self.tableData.count {
                let cell = self.purchases.cellForRow(at: indexPath) as! AdditionalPurchase
                
                if cell.didCheck{
                    self.cart[cartOrder[indexPath.section]]?.append([
                        cell.name.text!,
                        cell.price.text!,
                        cell.amount.text!
                    ])
                }
            }
        }
    }
}
