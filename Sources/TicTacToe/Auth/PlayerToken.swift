//
//  PlayerToken.swift
//  TicTacToe
//
//  Created by James Weatherley on 11/11/2026.
//

import Vapor
import Fluent

final class PlayerToken: Model, Content, @unchecked Sendable {
    static let schema = "player_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "player_id")
    var player: Player

    @OptionalField(key: "expires_at")
    var expiresAt: Date?

    init() {}

    init(id: UUID? = nil, value: String, playerID: Player.IDValue, expiresAt: Date? = nil) {
        self.id = id
        self.value = value
        self.$player.id = playerID
        self.expiresAt = expiresAt
    }
}

struct CreatePlayerToken: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("player_tokens")
            .id()
            .field("value", .string, .required)
            .field("player_id", .uuid, .required, .references("players", "id", onDelete: .cascade))
            .field("expires_at", .datetime)
            .unique(on: "value")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("player_tokens").delete()
    }
}
