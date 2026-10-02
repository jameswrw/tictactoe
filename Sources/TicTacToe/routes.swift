import Vapor

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

}
