//
//  PayRollModel.swift
//  apiParalelo
//
//  Created by Markel Juaristi Mendarozketa   on 29/2/24.
//

import Foundation

struct PayrollRequest: Codable {
    let id: Int
    let name: String
    let surname: String
    let company: String
    let salary: Double
}

struct PayrollResponse: Codable {
    let name: String
    let surname: String
    let job: String
    let company: String
    let salary: Double
    let total: Double
}


