//
//  DefaultDummyRepository.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import Foundation
import Networkable
import RxSwift

protocol DummyRepository {
    func getUsers(paging: Paging?) -> Observable<Result<BaseResponse<[User]>, Error>>
}

final class DefaultDummyRepository: DummyRepository {
    static let shared = DefaultDummyRepository()
    
    var dataService: DataService
    // MARK: - Init
    
    init(dataService: DataService = RxDataService()) {
        self.dataService = dataService
    }
    
    func getUsers(paging: Paging?) -> Observable<Result<BaseResponse<[User]>, Error>> {
        return dataService.buildObservable(APIEndpoint.getUsers(paging: paging))
    }
    
    
}

extension DefaultDummyRepository {
    
    enum APIEndpoint: Endpoint {
        case getUsers(paging: Paging?)
        
        var url: String {
            let apiBaseUrl = BASE_URL
            switch self {
            case let .getUsers(paging):
                var result: String = apiBaseUrl + "/user"
                if let paging = paging {
                    result += "?page=\(paging.page)&limit=\(paging.limit)"
                }
                return result
            }
        }
        
        var method: Networkable.Method {
            switch self {
            case .getUsers:
                return .get
            }
        }
        
        func body() throws -> Data? {
            return nil
        }
    }
}
