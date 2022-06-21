//
//  DataService.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import Foundation
import Networkable
import RxSwift
import RxCocoa

public protocol DataService {
    func buildObservable<T: Decodable>(_ endPoint: Endpoint) -> Observable<Result<T, Error>>
}

class RxDataService: DataService {
    
    let session: URLSession
    let requestFactory: URLRequestFactory
    let middlewares: [Middleware]
    let decoder: JSONDecoder = JSONDecoder()
    
    init(
        requestFactory: URLRequestFactory = DefaultURLRequestFactory(baseURL: URL(string: BASE_URL)),
        middlewares: [Middleware] = [],
        session: URLSession = .shared
    ) {
        self.requestFactory = requestFactory
        self.middlewares = middlewares
        self.session = session
    }
    
    private func buildRequest(endPoint: Endpoint) throws -> URLRequest {
        let middlewares = self.middlewares
        var request = try requestFactory.make(endpoint: endPoint)
        
        for middleware in middlewares {
            request = try middleware.prepare(request: request)
        }
        
        return request
    }
    
    func buildObservable<T: Decodable>(_ endPoint: Endpoint) -> Observable<Result<T, Error>> {
        do {
            let request = try buildRequest(endPoint: endPoint)
            return session.rx.response(request: request)
                .map({ (response, data) -> (Result<T, Error>) in
                    do {
                        for middleware in self.middlewares {
                            do {
                                try middleware.didReceive(response: response, data: data)
                            } catch let er {
                                print(er)
                            }
                        }
                        let result = try self.decoder.decode(T.self, from: data)
                        return .success(result)
                    } catch let err {
                        return .failure(err)
                    }
                })
        } catch {
            return Observable.just(.failure(error))
        }
    }
}
