//
//  ConnectionManagerStorageKey.swift
//  TicTacToe
//
//  Created by James Weatherley on 14/11/2026.
//

import Foundation

import JWTKit
import Vapor

struct ConnectionManagerStorageKey: StorageKey {
    typealias Value = ConnectionManager
}

