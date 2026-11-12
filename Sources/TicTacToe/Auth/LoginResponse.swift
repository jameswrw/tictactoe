//
//  LoginResponse.swift
//  TicTacToe
//
//  Created by James Weatherley on 12/11/2026.
//

import Foundation
import Vapor
 
struct LoginResponse: Content {
    let token: String
    let player: Player
}
