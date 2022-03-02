//
//  OrdersTableViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/8/10.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class OrdersTableViewController: UITableViewController {
    var historyOrders: [[String]] = []
    let tools = Tools()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.present(tools.loadingView(type: "loading"), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getHistories()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyOrders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OrderCell
        cell.restarantName.text = historyOrders[indexPath.row][1]
        cell.cost.text = historyOrders[indexPath.row][3]
        cell.time.text = historyOrders[indexPath.row][4]
        cell.restaurantImage.image = UIImage(named: "noIMG")
        cell.restarantName.textColor = .white
        cell.cost.textColor = .white
        cell.time.textColor = .white
        cell.contentView.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 1)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let navigator = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "OrderDetailNavigator") as! UINavigationController
        let controller = navigator.viewControllers.first as! OrderDetailViewController
        controller.orderId = self.historyOrders[indexPath.row][0]
        navigator.modalPresentationStyle = .fullScreen
        present(navigator, animated: true, completion: nil)
    }
    
    @objc func dismissLoadingView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func getHistories(){
        self.historyOrders = []
        
        let param = tools.toHttpPostData(data: [
            "user": UserDefaults.standard.string(forKey: "user")!
        ])
        guard let url = URL(string: "http://localhost:8080/WebApp/getOrders") else {return}
        var req = URLRequest(url: url)
        req.httpMethod = "post"
        req.httpBody = param.data(using: .utf8)
        
        let session = URLSession.shared
        session.dataTask(with: req){ (data, res, err) in
            if let data = data{
                do{
                    let result = try JSONDecoder().decode(Orders.self, from: data)
                    if result.status{
                        DispatchQueue.main.async {
                            for order in result.orders{
                                let order = [
                                    String(order.id),
                                    order.restaurantName,
                                    order.restaurantId,
                                    order.cost,
                                    order.time
                                ]
                                self.historyOrders.append(order)
                            }
                            
                            self.tableView.reloadData()
                            _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.dismissLoadingView), userInfo: nil, repeats: false)
                        }
                    }
                    else{
                        print("error occur while getting orders!")
                    }
                }catch{
                    print(error)
                }
            }
        }.resume()
    }
}
