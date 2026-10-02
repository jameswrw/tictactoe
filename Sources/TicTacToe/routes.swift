import Vapor
import Fluent
import FluentPostgresDriver

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    app.get("hello", ":name") { req -> String in
        let name = req.parameters.get("name")!
        return "Hello, \(name)!"
    }
    
    app.get("address", "chiswick") { req -> Address in
        Address(houseNumber: 64, houseName: nil, firstLine: "Chiswick Village", secondLine: nil, city: "London", postcode: "W4 3BZ")
    }
    
    app.get("address", "banchory") { req -> Address in
        Address(houseNumber: 19, houseName: "Dunnottar", firstLine: "Station Road", secondLine: nil, city: "Banchory", postcode: "AB31 5XX")
    }
    
    app.get("person", "chiswick") { req -> Person in
        Person(firstName: "James", surname: "Weatherley", age: 52)
    }

    app.post("createPlayer") { req async throws -> HTTPStatus in
        
        struct PostPlayer: Decodable {
            let firstName: String
            let lastName: String
        }
        
        // Decode the JSON body into our Todo struct
        let postPlayer = try req.content.decode(PostPlayer.self)
        
        // Print or save the data (e.g., to a database)
        print("Received player: \(postPlayer.firstName) \(postPlayer.lastName)")
        
        let player = Player(firstName: postPlayer.firstName, lastName: postPlayer.lastName)
        try await player.save(on: req.db)
        
        // Return a 201 Created status
        return .created
    }
}
