//
//  JWTKeysStorageKey.swift
//  TicTacToe
//
//  Created by James Weatherley on 14/11/2026.
//

import JWTKit
import Vapor

struct JWTKeysStorageKey: StorageKey {
    typealias Value = JWTKeyCollection
}
