import Vapor
import NIOWebSocket
import JWTKit
import JWT

struct AuthPayload: JWTPayload {
    func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
    
    // Customize claims to your app's needs
    var subject: SubjectClaim
    var expiration: ExpirationClaim
}

func routes(_ app: Application) throws {
    try app.register(collection: PlayerController())
    try app.register(collection: MatchController())
    
    let connections = ConnectionManager() // actor or class, injected via app.storage in production

    app.webSocket("ws") { req, ws async in
        await connections.setup(req: req, ws: ws)
    }
}

