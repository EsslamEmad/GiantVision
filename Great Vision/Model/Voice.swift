//
//  Voice.swift
//  Great Vision
//
//  Created by Esslam Emad on 1/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import Foundation

struct Voice: Codable{
    var id: Int!
    var name: String!
    var phone: String!
    var nationality: String!
    var age: Int!
    var gender: Int!
    var address: String!
    var soundFile: String!
    enum CodingKeys: String, CodingKey{
        case id = "user_id"
        case name
        case phone
        case nationality
        case age
        case gender
        case address
        case soundFile = "sound_file"
    }
}
