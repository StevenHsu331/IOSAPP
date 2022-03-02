//
//  loginData.swift
//  iosApp
//
//  Created by 許景評 on 2021/8/12.
//  Copyright © 2021 許景評. All rights reserved.
//

import Foundation

class LoginData: Codable{
    var account: String
    var password: String
    
    init(account: String, password: String) {
        self.account = account
        self.password = password
    }
}

class APIResult: Codable{
    var status: Bool
    
    init(status: Bool) {
        self.status = status
    }
}

class LoginResult: Codable{
    var status: Bool
    var account: Bool
    var password: Bool
    
    init(status: Bool, account: Bool, password: Bool) {
        self.status = status;
        self.account = account;
        self.password = password;
    }
}

class SignUpResult: Codable{
    var status: Bool
    var account: Bool
    var password: Bool
    var number: Bool
    
    init(status: Bool, account: Bool, password: Bool, number: Bool) {
        self.status = status;
        self.account = account;
        self.password = password;
        self.number = number;
    }
}

class SignUpData: Codable{
    var name: String
    var account: String
    var password: String
    var number: String
    var gender: String
    
    init(name: String, account: String, password: String, number: String, gender: String) {
        self.name = name
        self.account = account
        self.password = password
        self.number = number
        self.gender = gender
    }
}

class UserName: Codable{
    var user: String
    
    init(user: String) {
        self.user = user
    }
}

class Product: Decodable{
    var user: String
    var name: String
    var price: String
    var amount: String
    var restaurantName: String
    var restaurantId: String
}

class CartList: Decodable{
    var status: Bool
    var products: [Product]
}

class address: Decodable{
    var address: String
}

class card: Decodable{
    var code: String
    var safetyCode: String
}

class UserInfo: Decodable{
    var status: Bool
    var name: String
    var number: String
    var cards: [String]
    var addresses: [String]
}

class Order: Decodable{
    var id: Int
    var restaurantName: String
    var restaurantId: String
    var cost: String
    var time: String
}

class Orders: Decodable{
    var status: Bool
    var orders: [Order]
}

class ProductInDetails: Decodable{
    var name: String
    var price: String
    var amount: String
}

class OrderDetails: Decodable{
    var status: Bool
    var products: [ProductInDetails]
}

class Restaurant: Decodable{
    var id: String
    var name: String
}

class Restaurants: Decodable{
    var status: Bool
    var restaurants: [Restaurant]
}

class profileData: Decodable{
    var status: Bool
    var profile: String
}
