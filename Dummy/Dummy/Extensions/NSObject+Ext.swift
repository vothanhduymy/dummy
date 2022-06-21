//
//  NSObject+Ext.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: Self.self)
    }
}
