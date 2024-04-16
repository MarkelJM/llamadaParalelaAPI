//
//  BaseAPIClient.swift
//  apiParalelo
//
//  Created by Markel Juaristi Mendarozketa   on 29/2/24.
//

import Foundation
import Alamofire
import Combine

class BaseAPIClient {
    private var isReachable: Bool = true
    private var sessionManager: Alamofire.Session!

    private var baseURL: URL {
        guard let url = URL(string: "https://mock-movilidad.vass.es/api/formacion") else {
            fatalError("Invalid URL")
        }
        return url
    }

    init() {
        self.sessionManager = Session()
        startListenerReachability()
    }

    func handler(error: Error?) -> BaseError? {
        if !self.isReachable { return .noInternetConnection }
        var baseError: BaseError?

        if error != nil {
            baseError = .generic
        }

        return baseError
    }
    
    func handleResponse<A: Codable>(success: @escaping (A) -> Void, failure: @escaping (BaseError) -> Void, dataResponse: AFDataResponse<A>) {
        if let baseError = self.handler(error: dataResponse.error)  {
            failure(baseError)
        } else if let responseObject = dataResponse.value {
            success(responseObject)
        } else {
            failure(.generic)
        }
    }

    func request(_ relativePath: String?, method: HTTPMethod = .get, headers: [String: String] = [:], parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default) -> DataRequest {
        let urlAbsolute = baseURL.appendingPathComponent(relativePath ?? "")
        return sessionManager.request(urlAbsolute, method: method, parameters: parameters, encoding: encoding, headers: HTTPHeaders(headers)).cURLDescription { print($0) }
    }
    
    func requestPublisher<T: Decodable>(relativePath: String?, method: HTTPMethod = .get, parameters: Parameters? = nil, urlEncoding: ParameterEncoding = JSONEncoding.default, type: T.Type = T.self, customHeaders: HTTPHeaders? = nil) -> AnyPublisher<T, BaseError> {
        guard let path = relativePath else {
            return Fail(error: BaseError.generic).eraseToAnyPublisher()
        }

        let urlAbsolute = baseURL.appendingPathComponent(path)
        
        return sessionManager.request(urlAbsolute, method: method, parameters: parameters, encoding: urlEncoding, headers: customHeaders)
            .validate()
            .publishDecodable(type: T.self, emptyResponseCodes: [204])
            .tryMap { response in
                switch response.result {
                case .success(let result):
                    return result
                case .failure:
                    throw BaseError.generic
                }
            }
            .mapError { [weak self] _ in
                self?.isReachable ?? false ? BaseError.generic : BaseError.noInternetConnection
            }
            .eraseToAnyPublisher()
    }


    private func startListenerReachability() {
        let networkReachabilityManager = NetworkReachabilityManager()
        networkReachabilityManager?.startListening(onUpdatePerforming: { status in
            self.isReachable = networkReachabilityManager?.isReachable ?? false
        })
    }
}
