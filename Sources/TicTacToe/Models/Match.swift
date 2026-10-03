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
    var player1: UUID
    
    @Field(key: "player_2_id")
    var player2: UUID
 
    @Field(key: "winner_id")
    var winner: UUID?
    
    @Field(key: "board")
    var board: String
    
    init() {}
    
    init(id: UUID? = nil, player1: UUID, player2: UUID, winner: UUID?, board: String = ".........") {
        self.id = id
        self.player1 = player1
        self.player2 = player2
        self.winner = winner
        self.board = board
    }
}
