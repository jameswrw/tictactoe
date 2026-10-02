//
//  Player.swift
//  hello
//
//  Created by James Weatherley on 02/10/2026.
//

import Foundation
import Fluent

final class Player: Model, @unchecked Sendable {
    static let schema = "players"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "last_name")
    var lastName: String
    
    init() {}
    
    init(id: UUID? = nil, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}
