//
//  Address.swift
//  hello
//
//  Created by James Weatherley on 30/09/2026.
//

import Foundation
import Vapor

struct Address: Content {
    let houseNumber: Int?
    let houseName: String?
    let firstLine: String
    let secondLine: String?
    let city: String
    let postcode: String
}
