//
//  PlayerController.swift
//  TicTacToe
//
//  Created by James Weatherley on 07/11/2026.
//

import Vapor
import Fluent
import FluentPostgresDriver

extension Player: Content {}

struct PlayerController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.post("player", "login", use: login)
        routes.get("player", ":playerID", "opponents", use: fetchOpponents)
        routes.post("player", "create", use: createPlayer)
    }
    
    func login(req: Request) async throws -> LoginResponse {
        
        struct Credentials: Decodable {
            let userName: String
            let password: String
        }
        
        let credentials = try req.content.decode(Credentials.self)
        
        let player = try await Player.query(on: req.db)
            .filter(\.$userName == credentials.userName)
            .first()

        guard let player,
              try Bcrypt.verify(credentials.password, created: player.hash) else {
            throw Abort(.badRequest)
        }
        
        let tokenValue = [UInt8].random(count: 32).base64
        let token = PlayerToken(
            value: tokenValue,
            playerID: try player.requireID(),
            expiresAt: Date().addingTimeInterval(60 * 60 * 24 * 30)
        )
        try await token.save(on: req.db)

        return LoginResponse(token: token.value, player: player)
    }
    
    func fetchOpponents(req: Request) async throws -> [Player] {
        guard let playerIDString = req.parameters.get("playerID"),
              let playerID = UUID(uuidString: playerIDString) else {
            throw Abort(.badRequest)
        }
        return try await Player.query(on: req.db)
            .filter(\.$id != playerID)
            .all()
    }
    
    func createPlayer(req: Request) async throws -> Player {
        struct PostPlayer: Decodable {
            let userName: String
            let password: String
            let firstName: String
            let lastName: String
        }
        
        let postPlayer = try req.content.decode(PostPlayer.self)
        let hash = try Bcrypt.hash(postPlayer.password)
        let player = Player(
            firstName: postPlayer.firstName,
            lastName: postPlayer.lastName,
            userName: postPlayer.userName,
            hash: hash
        )
        try await player.save(on: req.db)
        
        return player
    }
}
