//
//  ChatVC.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 6/10/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ChatVC: JSQMessagesViewController {

    var chatRoomId:String!
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var messages = [JSQMessage]()
    var userIsTypingRef: FIRDatabaseReference!
    
    private var localTyping: Bool = false
    var isTyping: Bool{
        get{
            return localTyping
        }
        set{
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeTypingUser()
        
        self.title = "Message" //TODO: Que aparezca el nombre del q estoy hablando
        
        let factory = JSQMessagesBubbleImageFactory()
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        //Para que no haya avatar en cada mensaje
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
       
        
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //Para recuperar todos los mensajes guardados en firebase
        let messageQuery = databaseRef.child("chatrooms").child(chatRoomId).child("messages").queryLimited(toLast: 30)
        messageQuery.observe(.childAdded, with: { (snapshot) in
            
            let values = snapshot.value as! Dictionary<String, Any>
            
            let senderId = values["senderId"] as? String
            let text = values["text"] as? String
            let displayName = values["username"] as? String
            
            self.addMessage(text: text!, senderId: senderId!, displayName: displayName!)
            self.finishReceivingMessage()  //Para actualizar el UI
            
            
        }) { (error) in
            
            print(error.localizedDescription)
        }
    }
    
    //Para monitorear si el usuario esta escribiendo
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        
        isTyping = textView.text != ""
    }
    
    private func observeTypingUser(){
        let typingRef = databaseRef.child("chatrooms").child(chatRoomId).child("typingIndicator")
        userIsTypingRef = typingRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        let userIsTypingQuery = typingRef.queryOrderedByValue().queryEqual(toValue: true)
        
        userIsTypingQuery.observe(.value, with: { (snapshot) in
            
            if snapshot.childrenCount == 1 && self.isTyping{
                return
            }
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottom(animated: true)
            
            
            }) { (error) in
                
                print(error.localizedDescription)
        }
        
        
    }
    
    //Func que toma el mensaje y lo agrega a un array
    private func addMessage(text:String, senderId:String, displayName:String){
        //TODO: Hacer un if let?
        let message = JSQMessage(senderId: senderId, displayName: displayName, text: text)
        messages.append(message!)
        
    }
    
    //Func para mandar mensajes (Es decir lo guardamos en firebase)
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let messageRef = databaseRef.child("chatrooms").child(chatRoomId).child("messages").childByAutoId()
        let message = Message(text: text, username: senderDisplayName, senderId: senderId)
        
        messageRef.setValue(message.toAny()) { (error, ref) in
            
            if error == nil{
                //Que haya un sonido cuando mando un mesaje
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
            }else{
                print(error?.localizedDescription)
            }
            
        }
        
    }
    

    //MARK: JSQViewController Methods : OBLIGATORIOS
    
    //Para configurar los colores de las Bubbles dependiendo de donde venga
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        //Si soy yo el senderId (message.senderId) quiero devolver la outgoingBubble
        if message.senderId == senderId{
            return outgoingBubbleImageView
        }else{
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        //Logica para ver de que lado va la bubble (dependiendo quien soy)
        if message.senderId == senderId{
            cell.textView.textColor = UIColor.white
        }else{
            cell.textView.textColor = UIColor.black
        }
        
        return cell
    }
}

