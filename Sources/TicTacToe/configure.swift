import Vapor
import Fluent
import FluentPostgresDriver

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    connectPostgre(app)
    
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
