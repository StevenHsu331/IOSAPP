//
//  OrderDetailViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/9/28.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class OrderDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var orderTable: UITableView!
    var orderId: String = ""
    var products: [[String]] = []
    let tools = Tools()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.orderTable.delegate = self
        self.orderTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getOrderDetails()
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.orderTable.dequeueReusableCell(withIdentifier: "cell") as! ProductCellInOrder
        if products.count != 0{
            cell.name.text = products[indexPath.row][0]
            cell.price.text = products[indexPath.row][1]
            cell.amount.text = products[indexPath.row][2]
        }
        cell.name.textColor = .white
        cell.price.textColor = .white
        cell.amount.textColor = .white
        cell.contentView.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 1)
        
        return cell
    }
    
    func getOrderDetails(){
        self.products = []
        let param = tools.toHttpPostData(data: [
            "user": UserDefaults.standard.string(forKey: "user")!,
            "id": orderId
        ])
        guard let url = URL(string: "http://localhost:8080/WebApp/getOrderDetails") else {return}
        var req = URLRequest(url: url)
        req.httpMethod = "post"
        req.httpBody = param.data(using: .utf8)
        
        let session = URLSession.shared
        session.dataTask(with: req){ (data, res, err) in
            if let data = data{
                do{
                    let result = try JSONDecoder().decode(OrderDetails.self, from: data)
                    if result.status{
                        DispatchQueue.main.async {
                            for product in result.products{
                                self.products.append([product.name, product.price, product.amount])
                            }
                            self.orderTable.reloadData()
                        }
                    }
                    else{
                        print("error occur while getting order details")
                    }
                }catch{
                    print(error)
                }
            }
        }.resume()
    }
}
