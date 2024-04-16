//
//  ListDataManager.swift
//  apiParalelo
//
//  Created by Markel Juaristi Mendarozketa   on 29/2/24.
//

import Foundation
import Combine

class ListDataManager {
    private var apiClientManager = ApiClientManager()
    var cancellables = Set<AnyCancellable>()

    func fetchNamesList() -> AnyPublisher<NameList, BaseError> {
        apiClientManager.fetchNames()
    }

    func fetchSurname(forUserId userId: Int) -> AnyPublisher<SurnameModel, BaseError> {
        apiClientManager.fetchSurname(forUserId: userId)
    }

    func fetchJob(forUserId userId: Int) -> AnyPublisher<JobModel, BaseError> {
        apiClientManager.fetchJob(forUserId: userId)
    }

    func fetchSalary(forUserId userId: Int) -> AnyPublisher<SalaryModel, BaseError> {
        apiClientManager.fetchSalary(forUserId: userId)
    }

    func postPayroll(body: PayrollRequest) -> AnyPublisher<PayrollResponse, BaseError> {
        apiClientManager.postPayroll(body: body)
    }
    

}
