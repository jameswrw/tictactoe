//
//  Person.swift
//  hello
//
//  Created by James Weatherley on 30/09/2026.
//

import Foundation
import Vapor

struct Person: Content {
    let firstName: String
    let surname: String
    let age: Int
}
