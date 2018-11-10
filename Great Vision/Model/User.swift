//
//  User.swift
//  Great Vision
//
//  Created by Esslam Emad on 1/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import Foundation

struct User: Codable {
    var name: String!
    var email: String!
    var id: Int!
    var phone: String!
    var password: String!
    var photo: String!
    var token: String!
    var height: Int!
    var weight: Int!
    var gender: Int!
    var nationality: String!
    var age: Int!
    var address: String!
    var skin: String!
    var works: String!
    
    enum CodingKeys: String, CodingKey{
        case name
        case email
        case id
        case phone
        case password
        case photo
        case token
        case height
        case weight
        case gender
        case nationality
        case age
        case address
        case skin = "skin_color"
        case works = "previous_works"
    }
}

extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}
