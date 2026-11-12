//
//  PlayerTokenAuthenticator.swift
//  TicTacToe
//
//  Created by James Weatherley on 12/11/2026.
//

import Vapor
import Fluent

struct PlayerTokenAuthenticator: AsyncBearerAuthenticator {
    typealias User = Player

    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        guard let token = try await PlayerToken.query(on: request.db)
            .filter(\.$value == bearer.token)
            .first() else {
            return
        }
        if let expiry = token.expiresAt, expiry < Date() {
            return
        }
        let player = try await token.$player.get(on: request.db)
        request.auth.login(player)
    }
}
