import Vapor
import Fluent
import FluentPostgresDriver

extension Player: Content {}

func routes(_ app: Application) throws {
    
    app.get("players") { req async throws -> [Player] in
        try await Player.query(on: req.db).all()
    }
    
    app.post("createPlayer") { req async throws -> HTTPStatus in
        
        struct PostPlayer: Decodable {
            let firstName: String
            let lastName: String
        }
        
        let postPlayer = try req.content.decode(PostPlayer.self)
        let player = Player(firstName: postPlayer.firstName, lastName: postPlayer.lastName)
        try await player.save(on: req.db)
        
        // Return a 201 Created status
        return .created
    }
}
