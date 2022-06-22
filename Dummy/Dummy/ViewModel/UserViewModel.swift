//
//  UserViewModel.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import Foundation
import RxSwift

class UserViewModel: BaseViewModel, BaseViewModelType {
    let repo: DefaultDummyRepository
    private let disposeBag = DisposeBag()
    var users: [UserListItem] = []
    var output: UserViewModel.Output
    var paging: Paging = Paging()
    
    struct Output {
        var isLoading: PublishSubject<Bool>
        var responseError: PublishSubject<ResponseError>
        var getUsers: PublishSubject<Bool>
        var getUser: PublishSubject<User>
    }
    
    init(repository: DefaultDummyRepository = DefaultDummyRepository.shared) {
        repo = repository
        self.output = Output(
            isLoading: PublishSubject<Bool>(),
            responseError: PublishSubject<ResponseError>(),
            getUsers: PublishSubject<Bool>(),
            getUser: PublishSubject<User>()
        )
    }
    
    func getUsers(isMore: Bool = false) {
        output.isLoading.onNext(true)
        if isMore {
            paging.page = users.count / paging.limit
        } else {
            paging.page = 0
        }
        repo.getUsers(paging: paging)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                self.output.isLoading.onNext(false)
                switch result {
                case .success(let response):
                    if let _users = response.data?.data {
                        if isMore {
                            self.users.append(contentsOf: _users)
                        } else {
                            self.users = _users
                        }
                        if _users.count < self.paging.limit {
                            self.output.getUsers.onNext(false)
                        } else {
                            self.output.getUsers.onNext(isMore)
                        }
                    }
                case .failure(let error):
                    self.output.responseError.onNext(error.toResponseError())
                }
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.output.isLoading.onNext(false)
                self.output.responseError.onNext(error.toResponseError())
            })
            .disposed(by: disposeBag)
    }
    
    func getUser(userListItem: UserListItem) {
        output.isLoading.onNext(true)
        repo.getUser(userListItem: userListItem)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                self.output.isLoading.onNext(false)
                switch result {
                case .success(let response):
                    if let _user = response.data {
                        self.output.getUser.onNext(_user)
                    }
                case .failure(let error):
                    self.output.responseError.onNext(error.toResponseError())
                }
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.output.isLoading.onNext(false)
                self.output.responseError.onNext(error.toResponseError())
            })
            .disposed(by: disposeBag)
    }
}
