//
//  Networking+Extension.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import Foundation
import Networkable
import RxSwift

extension Endpoint {
    
    var headers: [String : String]? {
        let dicHeader: [String : String] = [
            "Content-Type": "application/json",
            "app-id": API_ID,
        ]
        return dicHeader
    }

    func buildRequestBody<T: Encodable>(_ body: T, encoder: JSONEncoder = JSONEncoder()) throws -> Data?{
        return try encoder.encode(body)
    }
}
