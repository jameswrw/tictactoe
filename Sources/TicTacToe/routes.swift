import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: PlayerController())
    try app.register(collection: MatchController())
}
