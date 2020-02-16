//
//  ChatMessageModelController.swift
//  FirebaseChat
//
//  Created by Craig Swanson on 2/15/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import Foundation
import Firebase

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
        
        let requestURL = ChatMessageController.baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (possibleData, _, possibleError) in
            if let error = possibleError {
                NSLog("Error fetching chat rooms: \(error)")
                completion()
                return
            }
            
            guard let data = possibleData else {
                NSLog("No data returned from fetch Chat Rooms data task")
                completion()
                return
            }
            
            do {
                self.chatRooms = try JSONDecoder().decode([String: ChatRoom].self, from: data).map({ $0.value })
            } catch {
                self.chatRooms = []
                NSLog("Error decoding chat rooms from JSON data: \(error)")
            }
            completion()
        }.resume()
    }
    
    func createChatRoom(with roomName: String, completion: @escaping () -> Void) {
        
        let room = ChatRoom(roomName: roomName)
        
        let requestURL = ChatMessageController.baseURL.appendingPathComponent(room.roomID).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(room)
        } catch {
            NSLog("Error encoding chat room name to JSON: \(error)")
        }
        
        URLSession.shared.dataTask(with: request) { (possibleData, _, possibleError) in
            if let error = possibleError {
                NSLog("Error with chat room creation data task: \(error)")
                completion()
                return
            }
            self.chatRooms.append(room)
            completion()
            
        }.resume()
    }
    
    func createMessage(in chatRoom: ChatRoom, withText text: String, sender: Sender, completion: @escaping () -> Void) {
        
        guard let index = chatRooms.firstIndex(of: chatRoom) else { completion(); return }
        
        let message = ChatRoom.Message(messageText: text, sender: sender)
        
        chatRooms[index].messages.append(message)
        
        let requestURL = ChatMessageController.self.baseURL.appendingPathComponent(chatRoom.roomID).appendingPathComponent("messages").appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONEncoder().encode(message)
        } catch {
            NSLog("Error encoding message to JSON: \(error)")
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error with message thread creation data task: \(error)")
                completion()
                return
            }
            
            completion()
            
        }.resume()
    }
}
