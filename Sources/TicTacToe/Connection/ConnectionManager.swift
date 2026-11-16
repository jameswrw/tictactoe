//
//  ConnectionManager.swift
//  TicTacToe
//
//  Created by James Weatherley on 12/11/2026.
//

import NIOCore
import Vapor
import NIOWebSocket
import JWTKit

struct Connection {
    let userID: UUID
    let ws: WebSocket
    var lastPong: NIODeadline
}

actor ConnectionManager {
    private var connections: [UUID: Connection] = [:]
    
    func add(_ info: Connection) {
        connections[info.userID] = info
    }

    func remove(userID: UUID) {
        connections.removeValue(forKey: userID)
    }

    func get(userID: UUID) -> Connection? {
        connections[userID]
    }

    func updatePong(for userID: UUID) {
        if var info = connections[userID] {
            info.lastPong = .now()
            connections[userID] = info
        }
    }

    func forEach(_ body: (inout Connection) -> Void) {
        // If you need mutation, iterate keys then reassign
        for key in connections.keys {
            if var value = connections[key] {
                body(&value)
                connections[key] = value
            }
        }
    }
    
    func postMatch(_ match: Match, to userID: UUID) throws {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(MatchDTO(from: match))
            let payload = SocketMessage(type: .match, data: data)
            let payloadData = try encoder.encode(payload)
            postMessage(payloadData, to: userID)
        } catch {
            print("Failed to encode Match: \(error)")
            throw Abort(.internalServerError, reason: "Failed to encode match payload.")
        }
    }

    private func postMessage(_ data: Data, to userID: UUID) {
        guard let connection = connections[userID] else {
            return
        }
        if connection.ws.isClosed {
            return
        }
        // WebSocket.send is async; ensure we await to propagate backpressure correctly.
        connection.ws.send(data)
    }
    
    func setup(req: Request, ws: WebSocket) async {
        // 1) Authenticate the WS request (JWT, session, etc.)
        let userID: UUID
        do {
            userID = try await authenticate(req)
        } catch {
            try? await ws.close(code: .policyViolation)
            return
        }
        
        // 2) Register this live connection
        add(Connection(userID: userID, ws: ws, lastPong: .now()))
        
        // 3) Set up handlers
        ws.eventLoop.execute {
            ws.onText { ws, text in
                Task {
                    if text == #"{"type":"pong"}"# {
                        await self.updatePong(for: userID)
                    } else {
                        // handle other messages
                    }
                }
            }
            
            // 4) Cleanup on close
            ws.onClose.whenComplete { _ in
                Task {
                    await self.remove(userID: userID)
                }
            }
        }
    }
    
    func authenticate(_ req: Request) async throws -> UUID {
        guard let bearer = req.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        guard let keys = req.application.storage[JWTKeysStorageKey.self] else {
            throw Abort(.internalServerError, reason: "JWT keys not configured")
        }

        do {
            // Verify the token using configured JWT signers on the application
            do {
                let payload = try await keys.verify(bearer.token, as: AuthPayload.self)
                guard let uuid = UUID(uuidString: payload.subject.value) else {
                    throw Abort(.unauthorized)
                }
                return uuid
            } catch {
                // Log the underlying JWT error to diagnose:
                req.logger.error("JWT verification failed: \(String(describing: error))")
                throw Abort(.unauthorized)
            }
        }
    }
}
