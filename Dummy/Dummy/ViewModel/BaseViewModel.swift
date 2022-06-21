//
//  BaseViewModel.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import Foundation
import RxSwift

class BaseViewModel: NSObject {
    override init() {
        print("➽➽  \(Self.className)")
    }
    
    deinit {
        print("➤➤ deinit:  \(Self.className)")
    }
}

protocol BaseViewModelType {
    associatedtype Output
    
    var output : Output { get }
}
