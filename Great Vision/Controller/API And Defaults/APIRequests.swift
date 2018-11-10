//
//  APIRequests.swift
//  Great Vision
//
//  Created by Esslam Emad on 1/10/18.
//  Copyright © 2018 Alyom Apps. All rights reserved.
//

import Foundation
import Moya

enum APIRequests {
    
    
    case login(email: String, password: String)
    case editUser(variables: User, id: Int)
    case register(user: User)
    case forgotPassword(email: String)
    case updateToken(id: Int, token: String)
    case contactUs(name: String, email: String, message: String)
    case getPages
    case getPage(id: Int)
    case upload(image: UIImage?, file: URL?)
    case addActing(acting: Acting)
    case addFashion(fashion: Fashion)
    case addVoice(voice: Voice)
    case getCategories
    case getCategory(id: Int)
    
    
    
}


extension APIRequests: TargetType{
    var baseURL: URL{
        switch Auth.auth.language{
        case "en":
            return URL(string: "https://sh.alyomhost.net/vision/en/mobile")!
        default:
            return URL(string: "https://sh.alyomhost.net/vision/ar/mobile")!
        }
        
    }
    var path: String{
        switch self{
        case .register:
            return "register"
        case .login:
            return "login"
        case .editUser:
            return "editUser"
        case .forgotPassword:
            return "forgotPassword"
        case .updateToken:
            return "updateToken"
       
        case .contactUs:
            return "contactUs"
        case .getPages:
            return "pages"
        case .getPage(id: let id):
            return "pages/\(id)"
        case .upload:
            return "upload"
        case .getCategories:
            return "getCategory"
        case .getCategory(id: let id):
            return "getCategory/\(id)"
        case .addVoice:
            return "addVoice"
        case .addFashion:
            return "addFashion"
        case .addActing:
            return "addActing"
        }
    }
    
    
    var method: Moya.Method{
        switch self{
        case .upload, .contactUs,  .updateToken, .forgotPassword, .editUser, .login, .register, .addVoice, .addFashion, .addActing:
            return .post
            
        default:
            return .get
        }
    }
    
    
    
    var task: Task{
        switch self{
            
        case .register(user: let user1):
            return .requestJSONEncodable(user1)
        case .login(email: let email, password: let password):
            return .requestParameters(parameters: ["email": email, "password": password], encoding: JSONEncoding.default)
        case.editUser(variables: let dict, id: let id):
            var dic = dict.dictionary
            dic["user_id"] = id
            return.requestParameters(parameters: dic, encoding: JSONEncoding.default)
            //return .requestJSONEncodable(dict)
        case .forgotPassword(email: let email):
            return .requestParameters(parameters: ["email": email], encoding: JSONEncoding.default)
        case .updateToken(id: let id , token: let token):
            return .requestParameters(parameters: ["user_id": id, "token": token], encoding: JSONEncoding.default)
        case .addActing(acting: let acting):
            return .requestJSONEncodable(acting)
        case .addVoice(voice: let voice):
            return .requestJSONEncodable(voice)
        case .addFashion(fashion: let fashion):
            return .requestJSONEncodable(fashion)
        case .contactUs(name: let name, email: let email , message: let message):
            return .requestParameters(parameters: ["name": name, "email": email, "message": message], encoding: JSONEncoding.default)
        case .upload(image: let image,file: let url):
            if let image = image{
            let data = image.jpegData(compressionQuality: 0.75)!
            let imageData = MultipartFormData(provider: .data(data), name: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
                let multipartData = [imageData]
               return .uploadMultipart(multipartData)
            }
            else if let data = NSData(contentsOfFile: url!.path){
                
                print(url?.path)
                let fileData = MultipartFormData(provider: .data(data as Data), name: "image", fileName: "record.m4a", mimeType: "audio/m4a")
                let multipartData = [fileData]
                return .uploadMultipart(multipartData)
                }
            
       return .requestPlain
        default:
            return .requestPlain
            
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return ["Content-type": "application/json",
                "client": "bd774529461ec185caaa6e66054a25ea53b487e3",
                "secret": "4f2a196e7a53e45593779276da68b164cfe8b798"]
    }
}
