//
//  MatchController.swift
//  TicTacToe
//
//  Created by James Weatherley on 07/11/2026.
//

import Vapor
import Fluent
import FluentPostgresDriver

extension Match: Content {}

struct MatchController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        
        let protected = routes.grouped("match").grouped(
            PlayerTokenAuthenticator(),
            Player.guardMiddleware()
        )
        
        protected.post("create", use: createMatch)
        protected.post(":matchID", "play", use: playMove)
        protected.get("featuring", ":player1ID", "versus", ":player2ID", use: fetchMatchesFeaturingPlayers)
    }
    
    func fetchMatchesFeaturingPlayers(req: Request) async throws -> [Match] {
        guard
            let uuid1String = req.parameters.get("player1ID"),
            let player1ID = UUID(uuid1String),
            let uuid2String = req.parameters.get("player2ID"),
            let player2ID = UUID(uuid2String) else {
            throw Abort(.badRequest)
        }

        let player1v2 = try await Match.query(on: req.db)
            .filter(\.$player1 == player1ID)
            .filter(\.$player2 == player2ID)
            .all()
        
        let player2v1 = try await Match.query(on: req.db)
            .filter(\.$player1 == player2ID)
            .filter(\.$player2 == player1ID)
            .all()
        
        return player1v2 + player2v1
    }
    
    func playMove(req: Request) async throws -> Match {
        struct PostMove: Decodable {
            let player: UUID
            let row: Int
            let col: Int
            let symbol: String
        }
        
        let move = try req.content.decode(PostMove.self)
        let match = try await matchFrom(uuidString: req.parameters.get("matchID"), database: req.db)
        
        guard move.player == match.player1 || move.player == match.player2 else {
            throw Abort(.badRequest)
        }
        guard match.winner == nil else {
            throw Abort(.badRequest)
        }
        
        let index = move.row * 3 + move.col
        let stringIndex = match.board.index(match.board.startIndex, offsetBy: index)
        let oldMove = match.board[stringIndex]
        guard oldMove == "." else {
            throw Abort(.badRequest)
        }
        
        match.board.replaceSubrange((stringIndex...stringIndex), with: move.symbol)
        checkForWin(match: match, player: move.player, symbol: move.symbol)
        try await match.save(on: req.db)
        
        return match
    }
    
    func createMatch(req: Request) async throws -> Match {
        struct PostMatch: Decodable {
            let player1: UUID
            let player2: UUID
        }
        
        let postMatch = try req.content.decode(PostMatch.self)
        guard postMatch.player1 != postMatch.player2 else {
            throw Abort(.badRequest)
        }
        
        let match = Match(player1: postMatch.player1, player2: postMatch.player2, winner: nil)
        try await match.save(on: req.db)
        
        return match
    }
    
    // MARK: - Utils
    @Sendable func checkForWin(match: Match, player: UUID, symbol: String) {
        let cells = Array(match.board)
        guard cells.count == 9 else {
            return
        }

        let winningLines = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]

        let isWin = winningLines.contains { line in
            line.allSatisfy { String(cells[$0]) == symbol }
        }

        if isWin {
            match.winner = player
        }
    }
    
    @Sendable func matchFrom(uuidString: String?, database: any Database) async throws -> Match {
        var match: Match? = nil
        if let matchID = UUID(uuidString: uuidString ?? "") {
            match = try await Match.query(on: database)
                .filter(\.$id == matchID)
                .first()
        }
        
        if let match {
            return match
        }
        
        throw Abort(.notFound)
    }
}
