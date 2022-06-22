//
//  User.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import Foundation
import ObjectMapper

struct UpdateUser: Mappable, Codable {
    var id: String?
    var firstName: String?
    var lastName: String?
    
    init() {}
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        //id                  <- map["id"]
        firstName           <- map["firstName"]
        lastName            <- map["lastName"]
    }
}

struct UserListItem: Mappable, Codable {
    var id: String = ""
    var title: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var picture: String = ""
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id                  <- map["id"]
        title               <- map["title"]
        firstName           <- map["firstName"]
        lastName            <- map["lastName"]
        picture             <- map["picture"]
    }
}

struct User: Mappable, Codable {
    var id: String = ""
    var title: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var picture: String = ""
    
    var gender: String = ""
    var email: String = ""
    var dateOfBirth: String = ""
    var phone: String = ""
    var location: Location?
    var registerDate: String = ""
    var updatedDate: String = ""
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id                  <- map["id"]
        title               <- map["title"]
        firstName           <- map["firstName"]
        lastName            <- map["lastName"]
        picture             <- map["picture"]
        
        gender              <- map["gender"]
        email               <- map["email"]
        dateOfBirth         <- map["dateOfBirth"]
        phone               <- map["phone"]
        location            <- map["location"]
        registerDate        <- map["registerDate"]
        updatedDate         <- map["updatedDate"]
    }
}

struct Location: Mappable, Codable {
    var street: String = ""
    var city: String = ""
    var state: String = ""
    var country: String = ""
    var timezone: String = ""
    
    init?(map: Map) {
        self.mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        street      <- map["street"]
        city        <- map["city"]
        state       <- map["state"]
        country     <- map["country"]
        timezone    <- map["timezone"]
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
