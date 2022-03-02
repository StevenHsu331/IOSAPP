//
//  MenuTableViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/8/3.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    var restaurantId: String = ""
    var restaurantName: String = ""
    let products: [[String]] = [
        ["cheese burger", "120"],
        ["double beef burger", "140"],
        ["fries", "50"],
        ["coke", "30"],
        ["ice cream", "20"]
    ]
    let tools = Tools()
    
    @IBOutlet var menuTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "product", for: indexPath) as! ProductCell
        cell.name.text = products[indexPath.row][0]
        cell.price.text = products[indexPath.row][1]
        cell.picture.image = UIImage(named: "noIMG")
        cell.restaurantId = self.restaurantId
        cell.restaurantName = self.restaurantName
        cell.amountBtn.tintColor = .white
        cell.layer.backgroundColor = tools.getRGB(r: 49, g: 49, b: 49)
        
        return cell
    }
}
