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
    func getUsers(paging: Paging?) -> Observable<Result<BaseResponse<[UserListItem]>, Error>>
    func getUser(userListItem: UserListItem) -> Observable<Result<BaseModel<User>, Error>>
    func updateUser(user: UpdateUser) -> Observable<Result<BaseModel<User>, Error>>
}

final class DefaultDummyRepository: DummyRepository {
    static let shared = DefaultDummyRepository()
    
    var dataService: DataService
    // MARK: - Init
    
    init(dataService: DataService = RxDataService()) {
        self.dataService = dataService
    }
    
    func getUsers(paging: Paging?) -> Observable<Result<BaseResponse<[UserListItem]>, Error>> {
        return dataService.buildObservable(APIEndpoint.getUsers(paging: paging))
    }
    
    func getUser(userListItem: UserListItem) -> Observable<Result<BaseModel<User>, Error>> {
        return dataService.buildObservable(APIEndpoint.getUser(user: userListItem))
    }
    
    func updateUser(user: UpdateUser) -> Observable<Result<BaseModel<User>, Error>> {
        return dataService.buildObservable(APIEndpoint.updateUser(user: user))
    }
}

extension DefaultDummyRepository {
    
    enum APIEndpoint: Endpoint {
        case getUsers(paging: Paging?)
        case getUser(user: UserListItem)
        case updateUser(user: UpdateUser)
        
        var url: String {
            let apiBaseUrl = BASE_URL
            switch self {
            case let .getUsers(paging):
                var result: String = apiBaseUrl + "/user"
                if let paging = paging {
                    result += "?page=\(paging.page)&limit=\(paging.limit)"
                }
                return result
            case let .getUser(userListItem):
                return apiBaseUrl + "/user/\(userListItem.id)"
            case let .updateUser(user):
                return apiBaseUrl + "/user/\(user.id ?? "")"
            }
        }
        
        var method: Networkable.Method {
            switch self {
            case .getUsers, .getUser:
                return .get
            case.updateUser:
                return .put
            }
        }
        
        func body() throws -> Data? {
            switch self {
            case .getUsers, .getUser:
                return nil
            case let .updateUser(user):
                var body: UpdateUser = UpdateUser()
                body.firstName = user.firstName
                body.lastName = user.lastName
                return try buildRequestBody(body)
            }
        }
    }
}
