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
    
    static let baseURL = URL(string: "https://fir-chat-3a173.firebaseio.com/")!
    var databaseReference: DatabaseReference!
    var chatRooms: [ChatRoom] = []
    var dataSnapshots: [DataSnapshot]! = []
    fileprivate var _refHandle: DatabaseHandle!
    var currentUser: Sender?
    
//    func configureDatabase() {
//        databaseReference = Database.database().reference()
//        // this next one listens for a new "child added" (messages addition)
//        _refHandle = self.databaseReference.child("messages").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
//            guard let strongSelf = self else { return }
//            strongSelf.messages.append(snapshot)
//            strongSelf.clientTable.insertRows(at: [IndexPath(row: strongSelf.messages.count-1, section: 0)], with: .automatic)
//        })
//    }
    
    func fetchChatRooms(completion: @escaping () -> Void) {
        
        // set the firebase reference and an observer
        databaseReference = Database.database().reference()
        
        databaseReference.child("chatRoom").observeSingleEvent(of: .value) { (snapshot) in
            guard let chatroomsByID = snapshot.value as? [String: ChatRoom] else {
                return
            }
            let chatRooms = Array<ChatRoom>(chatroomsByID.values)
            self.chatRooms = chatRooms
            completion()
        }
        
//        
//        databaseReference.child("chatRoom").observe(.value) { (snapshot) in
//            // code to execute when a child is added under "chatRoom"
//            // take the value from snapshot and add it to the array for the tableview datasource
//            let possibleRoom = snapshot.value as? [String: Any]
//            
//            guard let actualRoom = possibleRoom,
//                let roomName = actualRoom["roomName"] as? String,
//                let roomID = actualRoom["roomID"] as? String else { return }
//            
//            var possibleMessages: [ChatRoom.Message] = []
//            
//            self.databaseReference.child("chatRoom/messages").observeSingleEvent(of: .value) { (messageSnapshot) in
//                let possibleMessage = messageSnapshot.value as? [String: Any]
//                
//                guard let actualMessage = possibleMessage,
//                let messageID = actualMessage["messageID"] as? String,
//                let timestamp = actualMessage["timestamp"] as? NSNumber,
//                let displayName = actualMessage["displayName"] as? String,
//                let senderId = actualMessage["senderId"] as? String,
//                    let text = actualMessage["text"] as? String else { return }
//                
//                let currentSender = Sender(senderId: senderId, displayName: displayName)
//                
//                let formatter: DateFormatter = {
//                    let result = DateFormatter()
//                    result.dateStyle = .medium
//                    result.timeStyle = .medium
//                    return result
//                }()
//                
//                let messageTimestamp = Date(timeIntervalSince1970: TimeInterval(timestamp))
////                guard let messageTimestamp = formatter.date(from: timestamp) else { return }
//                
//                let newMessage = ChatRoom.Message(messageText: text, sender: currentSender, timestamp: messageTimestamp, messageId: messageID)
//                possibleMessages.append(newMessage)
//            }
//            
//            let newRoom = ChatRoom(roomName: roomName, roomID: roomID, messages: possibleMessages)
//            
//            self.chatRooms.append(newRoom)
//            print(self.chatRooms.count)
//            
//        }
    }
    
    func createChatRoom(with chatroom: ChatRoom, completion: @escaping (Error?) -> Void) {
        
        databaseReference = Database.database().reference()
        let newRoomReference = databaseReference.child("chatRoom").child(chatroom.roomID)
        
        newRoomReference.setValue(chatroom) { error, _ in
            completion(error)
        }
    }
    
    func createMessage(in chatRoom: ChatRoom, withText text: String, sender: Sender, completion: @escaping () -> Void) {
        
        guard let index = chatRooms.firstIndex(of: chatRoom) else { completion(); return }
        
        let message = ChatRoom.Message(messageText: text, sender: sender)
        
        chatRooms[index].messages.append(message)
        
    }
}
