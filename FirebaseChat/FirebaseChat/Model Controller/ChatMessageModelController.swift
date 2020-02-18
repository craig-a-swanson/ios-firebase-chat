//
//  ChatMessageModelController.swift
//  FirebaseChat
//
//  Created by Craig Swanson on 2/15/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import Foundation
import FirebaseDatabase

/*
 Create a model controller. Again referring to the Firebase guides and documentation, add the following functionality:
 Create a chat room in Firebase
 Fetch chat rooms from Firebase
 Create a message in a chat room in Firebase
 Fetch messages in a chat room from Firebase
 Feel free to create as many helper methods as you need to avoid repeating yourself.
 */

class ChatMessageController {
    
    var databaseReference = DatabaseReference()
    var chatRooms: [ChatRoom] = []
    var messages: [ChatRoom.Message] = []
    let roomReference = Database.database().reference(withPath: "chatRoom")
    let messageReference = Database.database().reference(withPath: "messages")
    var currentUser: Sender?
    
    
    func fetchChatRooms(completion: @escaping () -> Void) {
        
        // set the child observer
        roomReference.observe(.value) { (snapshot) in
            var newRooms: [ChatRoom] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let chatRoom = ChatRoom(snapshot: childSnapshot) {
                    newRooms.append(chatRoom)
                }
        }
            let sortedChatRooms = newRooms.sorted { $0.roomName < $1.roomName }
            DispatchQueue.main.async {
                self.chatRooms = sortedChatRooms
            }
            completion()
        }
     }

    
    func createChatRoom(with chatroom: ChatRoom, completion: @escaping (Error?) -> Void) {
        
        let newRoomReference = roomReference.child(chatroom.roomID)
        
        newRoomReference.setValue(chatroom.dictionaryRepresentation) { error, _ in
            completion(error)
        }
    }
    
    func fetchMessages(with chatRoom: ChatRoom, completion: @escaping () -> Void) {
        
        let messageChatReference = self.messageReference.child(chatRoom.roomID)
        var newMessages: [ChatRoom.Message] = []
        messageChatReference.observe(.value) { (snapshot) in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let message = ChatRoom.Message(snapshot: childSnapshot) {
                    newMessages.append(message)
                }
            }
            let sortedMessages = newMessages.sorted { $0.timestamp < $1.timestamp}
            DispatchQueue.main.async {
                chatRoom.messages = sortedMessages
            }
            completion()
        }
    }
    
    func createMessage(in chatRoom: ChatRoom, withText text: String, sender: Sender, completion: @escaping () -> Void) {

        let message = ChatRoom.Message(messageText: text, sender: sender)
        let messageChatReference = self.messageReference.child(chatRoom.roomID)
        let messageReference = messageChatReference.child(message.messageId)
        messageReference.setValue(message.dictionaryRepresentation)
    }
}
