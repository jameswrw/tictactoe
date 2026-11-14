import Vapor
import Fluent
import FluentPostgresDriver
import JWTKit
import JWT

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let keys = JWTKeyCollection()
    await keys.add(hmac: "SuperSekrit-KeySuperSekritKey-SuperSekritKey", digestAlgorithm: .sha256, kid: "ttt")
    app.storage[JWTKeysStorageKey.self] = keys

    connectPostgre(app)
    app.migrations.add(CreatePlayerToken())
    
    // register routes
    try routes(app)
}

fileprivate func connectPostgre(_ app: Application) {
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: "localhost",
                username: "james",
                password: "",
                database: "tictactoe",
                tls: .disable
            )
        ),
        as: .psql
    )
}
