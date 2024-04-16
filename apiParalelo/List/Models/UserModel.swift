//
//  UserModel.swift
//  apiParalelo
//
//  Created by Markel Juaristi Mendarozketa   on 29/2/24.
//

import Foundation

struct NameList: Codable {
    let names: [UserModel]
}

struct UserModel: Codable {
    let name: String
    let id: Int
}


