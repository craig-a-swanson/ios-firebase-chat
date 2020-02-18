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

// TODO: encoder needs to convert roomID and roomName to the correct json

class ChatRoom: Codable, Equatable {

    let roomID: String
    let roomName: String
    var messages: [Message]?
    
    init(roomID: String = UUID().uuidString, roomName: String, messages: [Message]? = []) {
        self.roomID = roomID
        self.roomName = roomName
        self.messages = messages
    }
    
    // convert a dictionary back to a message object to be used by the rest of the app
    convenience init? (snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String:Any],
            let roomID = value["roomID"] as? String,
            let roomName = value["roomName"] as? String else { return nil }

        self.init(roomID: roomID, roomName: roomName, messages: nil)
        
    }
    
    // convert a message to a dictionary
    var dictionaryRepresentation: [String: Any] {
        return ["roomID" : roomID as String,
                "roomName" : roomName as String]
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
        
        // convert a dictionary back to a message object to be used by the rest of the app
        init? (snapshot: DataSnapshot) {
            var dateFormatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yyy'T'HH:mm:SS"
                return formatter
            }
            guard let value = snapshot.value as? [String:Any],
                let messageID = value["messageID"] as? String,
                let messageText = value["text"] as? String,
                let timestamp = value["timestamp"] as? String,
                let date = dateFormatter.date(from: timestamp),
                let senderId = value["senderId"] as? String,
                let displayName = value["displayName"] as? String else { return nil }
            let sender = Sender(senderId: senderId, displayName: displayName)
            self.init(messageText: messageText, sender: sender, timestamp: date, messageId: messageID)
        }
        
        // convert a message to a dictionary
        var dictionaryRepresentation: [String: Any] {
           
            var dateFormatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yyy'T'HH:mm:SS"
                return formatter
            }
            
            return ["messageID" : messageId as String,
                    "text" : messageText as String,
                    "timestamp" : dateFormatter.string(from: timestamp),
                    "senderId" : senderId as String,
                    "displayName": displayName as String]
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
