//
//  Acting.swift
//  Great Vision
//
//  Created by Esslam Emad on 1/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import Foundation

struct Acting: Codable{
    var id: Int!
    var name: String!
    var nationality: String!
    var phone: String!
    var gender: Int!
    var height: Int!
    var weight: Int!
    var age: Int!
    var address: String!
    var skin: String!
    var hair: String!
    var eye: String!
    var boot: Int!
    var dress: Int!
    var favActor: String!
    var reason: String!
    var photos = [String]()
    
    enum CodingKeys: String, CodingKey{
        case id = "user_id"
        case name
        case nationality
        case phone
        case gender
        case height
        case weight
        case age
        case address
        case skin = "skin_color"
        case hair = "hair_color"
        case eye = "eye_color"
        case boot = "pot_size"
        case dress = "dress_size"
        case favActor = "favourite_actor"
        case reason = "why_be_actor"
        case photos = "selfie_photo"
    }
}
