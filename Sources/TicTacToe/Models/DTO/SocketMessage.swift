//
//  MessageDTO.swift
//  TicTacToe
//
//  Created by James Weatherley on 14/11/2026.
//

import Foundation

struct SocketMessage: Codable {
    enum MessageType: Codable {
        case match
    }
    
    let type: MessageType
    let data: Data
}
