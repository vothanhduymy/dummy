//
//  BaseResponse.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import Foundation

struct BaseResponse<T: Codable>: Codable {
    var result: Bool?
    var code, message: String?
    var validatedMessage: String?
    var messageHtml: String?
    var data: BaseModel<T>?
    var additional: String?
    
    var isSuccess: Bool {
        return result == true
    }
    
    var toResponseError: ResponseError {
        var error = ResponseError()
        error.code = code ?? ""
        error.message = message ?? ""
        error.messageHtml = messageHtml ?? ""
        return error
    }
}

enum BaseModel<T: Codable>: Codable {
    case string(String)
    case bool(Bool)
    case data(T)
    case arrayData([T])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(T.self) {
            self = .data(x)
            return
        }
        if let x = try? container.decode([T].self) {
            self = .arrayData(x)
            return
        }
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type ❗️❗️❗️"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .data(let x):
            try container.encode(x)
        case .arrayData(let x):
            try container.encode(x)
        case .bool(let x):
            try container.encode(x)
        }
    }

    var data: T? {
        switch self {
        case .data(let data):
            return data
        default:
            return nil
        }
    }

    var arrayData: [T]? {
        switch self {
        case .arrayData(let arrayData):
            return arrayData
        default:
            return nil
        }
    }

    var stringValue: String? {
        switch self {
        case .string(let s):
            return s
        default:
            return nil
        }
    }
}


struct ResponseError: LocalizedError, Codable {
    
    var code: String = ""
    var message: String = ""
    var messageHtml: String = ""
    
    var localizedDescription: String {
        return message
    }
    
    var errorDescription: String? {
        return message
    }
    
    var failureReason: String? {
        return message
    }
    
    var helpAnchor: String? {
        return code
    }
}
