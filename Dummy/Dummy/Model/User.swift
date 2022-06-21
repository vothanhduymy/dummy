//
//  User.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import Foundation
import ObjectMapper

struct User: Mappable, Codable {
    var id: String = ""
    var title: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var picture: String = ""
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id              <- map["id"]
        title           <- map["title"]
        firstName       <- map["firstName"]
        lastName        <- map["lastName"]
        picture         <- map["picture"]
    }
}

struct Paging: Mappable, Codable {
    var page: Int = 0
    var limit: Int = 20
    
    init() {}
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        page    <- map["page"]
        limit   <- map["limit"]
    }
}
