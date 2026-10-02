//
//  Match.swift
//  hello
//
//  Created by James Weatherley on 02/10/2026.
//

import Foundation
import Fluent

final class Match: Model, @unchecked Sendable {
    static let schema = "matches"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "player_1_id")
    var player1: String
    
    @Field(key: "player_2_id")
    var player2: String
 
    @Field(key: "winner")
    var winner: String?
    
    init() {}
    
    init(id: UUID? = nil, player1: String, player2: String, winner: String?) {
        self.id = id
        self.player1 = player1
        self.player2 = player2
        self.winner = winner
    }
}
