//
//  Fashion.swift
//  Great Vision
//
//  Created by Esslam Emad on 1/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import Foundation

struct Fashion: Codable{
    var id: Int!
    var name: String!
    var phone: String!
    var nationality: String!
    var weight: Int!
    var height: Int!
    var address: String!
    var age: Int!
    var gender: Int!
    var body: String!
    var skin: String!
    var hair: String!
    var eye: String!
    var boot: Int!
    var dress: Int!
    var abaya: Int!
    var jeans: Int!
    var tshirt: Int!
    
    enum CodingKeys: String, CodingKey{
        case id = "user_id"
        case name
        case phone
        case nationality
        case weight
        case height
        case address
        case age
        case gender
        case body = "body_type"
        case skin = "skin_color"
        case hair = "hair_color"
        case eye = "eye_color"
        case boot = "pot_size"
        case dress = "dress_size"
        case abaya = "abaya_size"
        case jeans = "jeans_size"
        case tshirt = "tshirt_size"
    }
}
