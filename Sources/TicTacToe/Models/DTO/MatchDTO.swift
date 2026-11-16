//
//  MatchDTO.swift
//  TicTacToe
//
//  Created by James Weatherley on 14/11/2026.
//

import Foundation

struct MatchDTO: Codable {
       let id: UUID?
       let player1: UUID
       let player2: UUID
       let winner: UUID?
       let board: String

       init(from match: Match) {
           self.id = match.id
           self.player1 = match.player1
           self.player2 = match.player2
           self.winner = match.winner
           self.board = match.board
       }
   }
