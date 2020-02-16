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
    
    var databaseReference: DatabaseReference!
    var messages: [ChatRoom] = []
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
    
}
