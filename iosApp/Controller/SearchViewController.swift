//
//  HomeViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/7/31.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var restaurantTable: UITableView!
    @IBOutlet weak var searchArea: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    let tools = Tools()
    var tableData: [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restaurantTable.delegate = self
        restaurantTable.dataSource = self
        searchArea.layer.cornerRadius = 12
        searchArea.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.present(tools.loadingView(type: "loading"), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getRestaurants()
    }
    
    @IBAction func search(_ sender: Any) {
        
    }
    
    @objc func dismissLoadingView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func getRestaurants(){
        self.tableData = []
        
        guard let url = URL(string: "http://localhost:8080/WebApp/getRestaurants") else {return}
        let session = URLSession.shared
        session.dataTask(with: url){ (data, res, err) in
            if let data = data{
                do{
                    let result = try JSONDecoder().decode(Restaurants.self, from: data)
                    if result.status{
                        for restaurant in result.restaurants{
                            self.tableData.append([restaurant.id, restaurant.name])
                        }
                        
                        DispatchQueue.main.async {
                            self.restaurantTable.reloadData()
                            _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.dismissLoadingView), userInfo: nil, repeats: false)
                        }
                    }
                }catch{
                    print(error)
                }
            }
        }.resume()
    }
}

extension SearchViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let MenuController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "MenuTableViewController") as! MenuTableViewController
            if let navigator = self.navigationController {
                MenuController.restaurantId = tableData[indexPath.row][0]
                MenuController.restaurantName = tableData[indexPath.row][1]
                navigator.pushViewController(MenuController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.layer.backgroundColor = tools.getRGB(r: 49, g: 49, b: 49)
        
        let headerTitle: UILabel = UILabel(frame: CGRect(x: 20, y: 5, width: 160, height: 40))
        headerTitle.text = "Recommanded:"
        headerTitle.textColor = .white
        headerTitle.font = headerTitle.font.withSize(22)
        view.addSubview(headerTitle)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
}

extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurant", for: indexPath) as! restaurantCell
        cell.restaurantName.text = tableData[indexPath.row][1]
        cell.restaurantImage.image = UIImage(named: "restaurant_default")
        cell.layer.backgroundColor = tools.getRGB(r: 49, g: 49, b: 49)
        cell.restaurantName.textColor = .white
        
        return cell
    }
}
