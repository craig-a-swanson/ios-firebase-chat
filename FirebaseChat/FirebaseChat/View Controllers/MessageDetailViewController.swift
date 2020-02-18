//
//  MessageDetailViewController.swift
//  FirebaseChat
//
//  Created by Craig Swanson on 2/14/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase

class MessageDetailViewController: MessagesViewController, InputBarAccessoryViewDelegate {
    
    // MARK: - Properties
    var chatMessageController: ChatMessageController?
    var chatRoom: ChatRoom?
    
    private lazy var formatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .medium
        result.timeStyle = .medium
        return result
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

}

extension MessageDetailViewController: MessagesDataSource {
    // --- Required Delegate Methods ---
    func currentSender() -> SenderType {
        if let currentUser = chatMessageController?.currentUser {
            return currentUser
        } else {
            return Sender(senderId: "foo", displayName: "bar")
        }
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        guard let chatRoom = chatRoom else { return 0 }
        return chatRoom.messages?.count ?? 0
    }
    
//    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
//        return 0
//    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        guard let chatRoom = chatRoom else { fatalError("No message found in thread")}
        guard let message = chatRoom.messages?[indexPath.item] else {
            fatalError("No message found in thread")
        }
        return message
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        let attrs = [NSAttributedString.Key.font :
            UIFont.preferredFont(forTextStyle: .caption1)]
        return NSAttributedString(string: name, attributes: attrs)
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        let attrs = [NSAttributedString.Key.font :
            UIFont.preferredFont(forTextStyle: .caption2)]
        return NSAttributedString(string: dateString, attributes: attrs)
    }
}

extension MessageDetailViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension MessageDetailViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .black
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue : .green
    }
    
    // Adds tails onto the messages
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        return .bubbleTail(corner, .curved)
    }
    
    // sets the senders first initial in the avatar circle view
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let initial = String(message.sender.displayName.first ?? Character(""))
        let avatar = Avatar(image: nil, initials: initial)
        avatarView.set(avatar: avatar)
    }
    
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        guard let chatRoom = chatRoom,
//            let currentSender = currentSender() as? Sender else { return }
//        
//        chatMessageController?.createMessage(in: chatRoom, withText: text, sender: currentSender) {
//            DispatchQueue.main.async {
//                self.messagesCollectionView.reloadData()
//            }
//        }
//    }
}
