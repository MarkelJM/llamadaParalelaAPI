//
//  ApiClientManager.swift
//  apiParalelo
//
//  Created by Markel Juaristi Mendarozketa   on 29/2/24.
//

import Foundation
import UIKit
import Combine
import Alamofire

class ApiClientManager: BaseAPIClient {
    func fetchNames() -> AnyPublisher<NameList, BaseError> {
        requestPublisher(relativePath: "names", type: NameList.self)
    }

    func fetchSurname(forUserId userId: Int) -> AnyPublisher<SurnameModel, BaseError> {
        requestPublisher(relativePath: "surname/\(userId)", type: SurnameModel.self)
    }

    func fetchJob(forUserId userId: Int) -> AnyPublisher<JobModel, BaseError> {
        requestPublisher(relativePath: "job/\(userId)", type: JobModel.self)
    }

    func fetchSalary(forUserId userId: Int) -> AnyPublisher<SalaryModel, BaseError> {
        requestPublisher(relativePath: "salary/\(userId)", type: SalaryModel.self)
    }

    func postPayroll(body: PayrollRequest) -> AnyPublisher<PayrollResponse, BaseError> {
        guard let parameters = try? body.toDictionary() else {
            print("Error convirtiendo PayrollRequest a diccionario")
            return Fail(error: BaseError.generic).eraseToAnyPublisher()
        }

        print("Enviando datos de nómina al servidor con los siguientes parámetros: \(parameters)")
        
        return requestPublisher(relativePath: "payroll", method: .post, parameters: parameters, urlEncoding: JSONEncoding.default, type: PayrollResponse.self)
    }
    /*
    func postPayrollMock(parameters: [String: Any]) -> AnyPublisher<PayrollResponse, BaseError> {
        print("Enviando mock de datos de nómina al servidor con los siguientes parámetros: \(parameters)")
        return requestPublisher(relativePath: "payroll", method: .post, parameters: parameters, urlEncoding: JSONEncoding.default, type: PayrollResponse.self)
    }
     */
}

extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]
        return dictionary
    }
}

