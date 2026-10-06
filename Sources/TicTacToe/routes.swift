import Vapor
import Fluent
import FluentPostgresDriver

extension Player: Content {}
extension Match: Content {}

struct PatchMatch: Decodable {
    let playerID: UUID
    let row: Int
    let col: Int
}

func routes(_ app: Application) throws {
    
    app.get("player") { req async throws -> [Player] in
        try await Player.query(on: req.db).all()
    }
    
    app.post("player", "create") { req async throws -> Player in
        
        struct PostPlayer: Decodable {
            let firstName: String
            let lastName: String
        }
        
        let postPlayer = try req.content.decode(PostPlayer.self)
        let player = Player(firstName: postPlayer.firstName, lastName: postPlayer.lastName)
        try await player.save(on: req.db)
        
        return player
    }
    
    app.post("match", "create") { req async throws -> Match in
        
        struct PostMatch: Decodable {
            let player1: UUID
            let player2: UUID
        }
        
        let postMatch = try req.content.decode(PostMatch.self)
        let match = Match(player1: postMatch.player1, player2: postMatch.player2, winner: nil)
        try await match.save(on: req.db)
        
        return match
    }
    
    app.get("match") { req async throws -> [Match] in
        try await Match.query(on: req.db).all()
    }
    
    app.get("match", ":matchID") { req async throws -> Match in
        try await matchFrom(uuidString: req.parameters.get("matchID"), database: req.db)
    }
    
    app.patch("match", ":matchID") { req async throws -> Match in
        
        let patchMatch = try req.content.decode(PatchMatch.self)
        let match = try await matchFrom(uuidString: req.parameters.get("matchID"), database: req.db)
        
        // Who's moving?
        let move: Character = if patchMatch.playerID == match.player1 {
            "X"
        } else if patchMatch.playerID == match.player2 {
            "O"
        } else {
            throw Abort(.notFound)
        }
        
        guard moveIfLegal(movePatch: patchMatch, match: match, newEntry: move) else {
            throw(Abort(.badRequest))
        }
        
        checkForWin(match: match, player: patchMatch.playerID, symbol: move)
        try await match.save(on: req.db)
        
        return match
    }
    
    @Sendable func moveIfLegal(movePatch: PatchMatch, match: Match, newEntry: Character) -> Bool {
        let offset = movePatch.col + 3 * movePatch.row
        let index = match.board.index(match.board.startIndex, offsetBy: offset)

        // No-one has won already, in range and cell is empty
        guard
            match.winner == nil,
            match.board.count == 9,
            (0...9).contains(offset),
            match.board[index...index] == "." else {
            return false
        }
        
        // Check it is the player's turn
        let xsPlayed = match.board
            .filter {$0 == "X"}
            .count
        let osPlayed = match.board
            .filter {$0 == "O"}
            .count
        
        guard (newEntry == "X" && xsPlayed == osPlayed) || (newEntry == "O" && xsPlayed == osPlayed - 1) else {
            return false
        }
        
        // Make move
        match.board.replaceSubrange(index...index, with: CollectionOfOne(newEntry))
        return true
    }
    
    @Sendable func checkForWin(match: Match, player: UUID, symbol: Character) {
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
            line.allSatisfy { cells[$0] == symbol }
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
