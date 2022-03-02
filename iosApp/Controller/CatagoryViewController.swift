//
//  catagoryViewController.swift
//  iosApp
//
//  Created by 許景評 on 2021/8/9.
//  Copyright © 2021 許景評. All rights reserved.
//

import UIKit

class CatagoryViewController: UICollectionViewController {
    
    let catagories: [[String]] = [
        ["Japenese", "JP"],
        ["Chinese", "CH"],
        ["American", "AM"],
        ["French", "FR"]
    ]
    var width: CGFloat = 0.0;
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        width = self.view.frame.width
        collectionLayout.minimumLineSpacing = 15
        collectionLayout.minimumInteritemSpacing = 10
        collectionLayout.itemSize = CGSize(width: width/2-15, height: width/2-15)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return catagories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: "catagory", for: indexPath) as! Catagory
        cell.title.text = catagories[indexPath.row][0]
        cell.title.textColor = .white
        cell.image.image = UIImage(named: catagories[indexPath.row][1])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "SearchViewController")
        if let navigator = self.navigationController{
            navigator.pushViewController(controller, animated: true)
        }
    }
}
