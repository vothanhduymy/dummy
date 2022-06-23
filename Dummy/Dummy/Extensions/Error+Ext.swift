//
//  Error+Ext.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import Foundation

extension Error {
    func toResponseError() -> ResponseError {
        if type(of: self) is NSError.Type,
           let e = self as NSError? {
            return ResponseError(error: String(e.code), data: DataError(data: e.domain))
        } else {
            return ResponseError(error: "", data: DataError(data: localizedDescription))
        }
    }
}
