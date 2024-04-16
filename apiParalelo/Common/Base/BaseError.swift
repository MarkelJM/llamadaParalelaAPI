//
//  BaseError.swift
//  apiParalelo
//
//  Created by Markel Juaristi Mendarozketa   on 29/2/24.
//

import Foundation


enum BaseError: Error {
    case generic
    case noInternetConnection

    func description() -> String {
        switch self {
        case .generic: return "Error genérico"
        case .noInternetConnection: return "No hay conexión a internet"
        }
    }
}

