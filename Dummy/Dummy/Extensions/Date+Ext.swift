//
//  Date+Ext.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 22/06/2022.
//

import Foundation

extension Date {
    static func dateFromString(string: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: string)
    }
}
