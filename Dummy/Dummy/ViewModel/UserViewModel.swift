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
    
    var output: UserViewModel.Output
    
    struct Output {
        var isLoading: PublishSubject<Bool>
        var responseError: PublishSubject<ResponseError>
        var getUser: PublishSubject<[User]>
    }
    
    init(repository: DefaultDummyRepository = DefaultDummyRepository.shared) {
        repo = repository
        self.output = Output(
            isLoading: PublishSubject<Bool>(),
            responseError: PublishSubject<ResponseError>(),
            getUser: PublishSubject<[User]>()
        )
    }
    
    func getUsers(paging: Paging = Paging()) {
        output.isLoading.onNext(true)
        repo.getUsers(paging: paging)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                self.output.isLoading.onNext(false)
                switch result {
                case .success(let response):
                    self.output.getUser.onNext(response.data?.data ?? [])
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
