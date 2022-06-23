//
//  DetailViewModel.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 22/06/2022.
//

import Foundation
import RxSwift

class DetailViewModel: BaseViewModel {
    let repo: DefaultDummyRepository
    private let disposeBag = DisposeBag()
    var user: User!
    var output: DetailViewModel.Output
    
    struct Output {
        var isLoading: PublishSubject<Bool>
        var responseError: PublishSubject<ResponseError>
        var updateUser: PublishSubject<Bool>
        var deleteUser: PublishSubject<String>
    }
    
    init(repository: DefaultDummyRepository = DefaultDummyRepository.shared) {
        repo = repository
        output = Output(
            isLoading: PublishSubject<Bool>(),
            responseError: PublishSubject<ResponseError>(),
            updateUser: PublishSubject<Bool>(),
            deleteUser: PublishSubject<String>()
        )
    }
    
    func changeName(firstName: String?, lastName: String?) {
        var userUpdate = UpdateUser()
        userUpdate.id = user.id
        userUpdate.firstName = firstName
        userUpdate.lastName = lastName
        
        output.isLoading.onNext(true)
        repo.updateUser(user: userUpdate)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                self.output.isLoading.onNext(false)
                switch result {
                case .success(let response):
                    if let _user = response.data {
                        self.user = _user
                        self.output.updateUser.onNext(true)
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
    
    func deleteUser() {
        output.isLoading.onNext(true)
        repo.deleteUser(user: user)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                self.output.isLoading.onNext(false)
                switch result {
                case .success(let response):
                    self.output.deleteUser.onNext(response.id ?? "")
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
