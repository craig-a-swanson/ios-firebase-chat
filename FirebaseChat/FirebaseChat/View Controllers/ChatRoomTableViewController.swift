//
//  ChatRoomTableViewController.swift
//  FirebaseChat
//
//  Created by Craig Swanson on 2/14/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    let chatMessageController = ChatMessageController()

    @IBOutlet weak var chatRoomTextField: UITextField!
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get current user from User Defaults, or create a user for the first time
        if let currentUserDictionary = UserDefaults.standard.value(forKey: "currentUser") as? [String:String] {
            let currentUser = Sender(dictionary: currentUserDictionary)
            chatMessageController.currentUser = currentUser
        } else {
            // Create an alert that asks the user for a username and saves it to User Defaults
            let alert = UIAlertController(title: "Set a username", message: nil, preferredStyle: .alert)
            var usernameTextField: UITextField!
            
            alert.addTextField { (textfield) in
                textfield.placeholder = "Username:"
                usernameTextField = textfield
            }
            
            let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
                // Take the text field's text and save to User Defaults
                let displayName = usernameTextField.text ?? "No Name"
                let id = UUID().uuidString
                let sender = Sender(senderId: id, displayName: displayName)
                
                UserDefaults.standard.set(sender.dictionaryRepresentation, forKey: "currentUser")
                self.chatMessageController.currentUser = sender
            }
            
            alert.addAction(submitAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chatMessageController.fetchChatRooms {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func createChatRoom(_ sender: UITextField) {
        chatRoomTextField.resignFirstResponder()
        
        guard let roomName = chatRoomTextField.text else { return }
        chatRoomTextField.text = ""
        
        chatMessageController.createChatRoom(with: roomName) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatMessageController.chatRooms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath)
        
        cell.textLabel?.text = chatMessageController.chatRooms[indexPath.row].roomName

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MessageDetailSegue" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                let messageDetailVC = segue.destination as? MessageDetailViewController else { return }
            
            
        }
    }
}
