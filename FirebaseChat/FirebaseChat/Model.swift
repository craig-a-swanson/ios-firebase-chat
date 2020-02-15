//
//  Model.swift
//  FirebaseChat
//
//  Created by Craig Swanson on 2/15/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import Foundation
import MessageKit
import Firebase

class ChatRoom: Codable, Equatable {
    
    let roomName: String
    let roomID: String
    var messages: [Message]
    
    init(roomName: String, roomID: String = UUID().uuidString, messages: [Message] = []) {
        self.roomName = roomName
        self.roomID = roomID
        self.messages = messages
    }
    
    enum RoomCodingKeys: String, CodingKey {
        case title
        case identifier
        case messages
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RoomCodingKeys.self)
        
        let roomName = try container.decode(String.self, forKey: .title)
        let roomID = try container.decode(String.self, forKey: .identifier)
        
        if let messages = try container.decodeIfPresent([String:Message].self, forKey: .messages) {
            self.messages = Array(messages.values)
        } else {
            self.messages = []
        }
        self.roomName = roomName
        self.roomID = roomID
    }
    
    struct Message: Codable, Equatable, MessageType {
        var sender: SenderType {
            return Sender(senderId: senderId, displayName: displayName)
        }
        var sentDate: Date {
            return timestamp
        }
        var kind: MessageKind {
            return .text(messageText)
        }
        
        var messageId: String
        let messageText: String
        let timestamp: Date
        let senderId: String
        let displayName: String
        
        init(messageText: String, sender: Sender, timestamp: Date = Date(), messageId: String = UUID().uuidString) {
            self.messageText = messageText
            self.displayName = sender.displayName
            self.senderId = sender.senderId
            self.timestamp = timestamp
            self.messageId = messageId
        }
        
        enum CodingKeys: String, CodingKey {
            case displayName
            case senderId
            case text
            case timestamp
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let messageText = try container.decode(String.self, forKey: .text)
            let displayName = try container.decode(String.self, forKey: .displayName)
            let senderId = try container.decode(String.self, forKey: .senderId)
            let timestamp = try container.decode(Date.self, forKey: .timestamp)
            
            let sender = Sender(senderId: senderId, displayName: displayName)
            self.init(messageText: messageText, sender: sender, timestamp: timestamp)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(displayName, forKey: .displayName)
            try container.encode(senderId, forKey: .senderId)
            try container.encode(timestamp, forKey: .timestamp)
            try container.encode(messageText, forKey: .text)
        }
    }
    
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        return lhs.roomName == rhs.roomName &&
            lhs.roomID == rhs.roomID &&
            lhs.messages == rhs.messages
    }
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}
