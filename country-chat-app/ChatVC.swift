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
import MobileCoreServices
import AVKit
import SDWebImage

class ChatVC: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var chatRoomId:String!
    var otherUsername:String!
    //let photoCache = NSCache<NSString, AnyObject>()
    
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
        
        self.title = "Messages" //TODO: Que aparezca el nombre del q estoy hablando
        
        let factory = JSQMessagesBubbleImageFactory()
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        //Para que no haya avatar en cada mensaje
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
       
        //Put a background to the chat. TODO: Que el usuario pueda agregar el que quiera
        collectionView.backgroundView = UIImageView(image: UIImage(named: "whatsappbg"))
        
        fetchMessages()
    }

    
    //Para recuperar todos los mensajes guardados en firebase
    func fetchMessages(){
        
        let messageQuery = databaseRef.child("chatrooms").child(chatRoomId).child("messages").queryLimited(toLast: 30)
        
        messageQuery.observe(.childAdded, with: { (snapshot) in
            
            let values = snapshot.value as! Dictionary<String, Any>
            
            let senderId = values["senderId"] as! String
            let text = values["text"] as! String
            let displayName = values["username"] as! String
            let mediaType = values["mediaType"] as! String
            let mediaUrl = values["mediaUrl"] as! String

            //let startTime = CFAbsoluteTimeGetCurrent() //Numero mas alto es mas rapido
            
            switch mediaType{
            case "Text":
                
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, text: text))
             
//                print("Text message: \(CFAbsoluteTimeGetCurrent() - startTime)")
            case "Image":
        //MANUALMENTE
//                var photo = JSQPhotoMediaItem(image: nil)!
//                
//                //Si ya se bajo la imagen anteriormente, no neceistamos que se baje de nuevo (Cache)
//                if let cachedPhoto = self.photoCache.object(forKey: mediaUrl as NSString) as? JSQPhotoMediaItem{
//                    //No hace falta bajar de nuevo la imagen
//                    
//                    photo = cachedPhoto
//                    self.collectionView.reloadData()
//                }else{
//                    //Hay q bajar de nuevo la img
//                    
//                    //Para ejecutar algo(muy pesado) en background thread y hacer mas rapido el NSData
//                    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
//                        let data = NSData(contentsOf: URL(string: mediaUrl)!) //Func lenta
//                        //Siempre todo lo que es UI tiene que ser ejecutado en la Main Queue
//                        DispatchQueue.main.async {
//                            
//                            let picture = UIImage(data: data as! Data)
//                            photo.image = picture
//                            self.collectionView.reloadData()
//                            
//                            //Lo pongo en el cache par a la porixima
//                            self.photoCache.setObject(photo, forKey: mediaUrl as NSString)
//                        }
//                        
//                    }
//                }
          
                //Lo mismo pero con REPO (Mejor)
                let photo = JSQPhotoMediaItem(image: nil)!
                let downloader = SDWebImageDownloader.shared()
                downloader!.downloadImage(with: URL(string:mediaUrl), options: [], progress: nil, completed: { (image, data, error, finished) in
                    
                    DispatchQueue.main.async {
                        
                        photo.image = image
                        self.collectionView.reloadData()
                    }
                    
                })
                
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: photo))
                
                if self.senderId == senderId{
                    photo.appliesMediaViewMaskAsOutgoing = true
                }else{
                    photo.appliesMediaViewMaskAsOutgoing = false
                }
                
                //print("Image message: \(CFAbsoluteTimeGetCurrent() - startTime)")

                
            case "Video":
                
                
                if let url = URL(string: mediaUrl){
                    
                    let video = JSQVideoMediaItem(fileURL: url, isReadyToPlay: true)
                    self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: video))
                    
                    //print("Video message: \(CFAbsoluteTimeGetCurrent() - startTime)")

                    
                }
             
            default:
                break
            }
            self.collectionView.reloadData()
            self.finishReceivingMessage()
            
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
    
    
    //Func para mandar mensajes (Es decir lo guardamos en firebase)
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let messageRef = databaseRef.child("chatrooms").child(chatRoomId).child("messages").childByAutoId()
        let message = Message(text: text, username: senderDisplayName, senderId: senderId, mediaType: "Text", mediaUrl: "")
        
        messageRef.setValue(message.toAny()) { (error, ref) in
            
            if error == nil{
                //Para setear el lastMessage de la conversacion en firebase
                let lastMessageRef = databaseRef.child("chatrooms").child(self.chatRoomId).child("lastMessage")
                lastMessageRef.setValue(text, withCompletionBlock: { (error, ref) in
                    
                    if error == nil{
                        //Para notificar al ChatListVC sobre el cambio en lastMessage
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateChats"), object: nil)
                        
                    }else{
                        print(error!.localizedDescription)
                    }
                })
                
                //Para setear el timestamp del ultimo mensaje en firebase
                let timestampRef = databaseRef.child("chatrooms").child(self.chatRoomId).child("timestamp")
                timestampRef.setValue(NSDate().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                    
                    if error == nil{
                    
                        
                    }else{
                        print(error!.localizedDescription)
                    }
                })
                
                //Que haya un sonido cuando mando un mesaje
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
            }else{
                print(error!.localizedDescription)
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
        
        if !message.isMediaMessage{   //Si no tiene media el mensaje
            //Logica para ver de que lado va la bubble (dependiendo quien soy)
            if message.senderId == senderId{
                cell.textView.textColor = UIColor.white
            }else{
                cell.textView.textColor = UIColor.black
            }
        }
        
        
        return cell
    }
    
    //Para ver los videos en la app
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let message = messages[indexPath.item]
        
        if message.isMediaMessage{
            if let media = message.media as? JSQVideoMediaItem{
                let videoplayer = AVPlayer(url: media.fileURL)
                let avplayerviewcontroller = AVPlayerViewController()
                avplayerviewcontroller.player = videoplayer
                present(avplayerviewcontroller, animated: true, completion: nil)
            }
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let alertcontroller = UIAlertController(title: "Media", message: "Choose your media type", preferredStyle: .actionSheet)
        
        let imageAction = UIAlertAction(title: "Image", style: .default) { (action) in
            self.getMedia(mediaType: kUTTypeImage)
            
        }
        let videoAction = UIAlertAction(title: "Video", style: .default) { (action) in
            self.getMedia(mediaType: kUTTypeMovie)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertcontroller.addAction(imageAction)
        alertcontroller.addAction(videoAction)
        alertcontroller.addAction(cancelAction)
        
        present(alertcontroller, animated: true, completion: nil)
        
    }
    
    
    //Save image and videos in firebase
    private func saveMediaMessage(withImage image:UIImage?, withVideo: URL?){
        
        if let image = image{
            let imagePath = "messageWithMedia\(chatRoomId + NSUUID().uuidString)/photo.jpg"
            let imageRef = storageRef.child(imagePath)
            
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let imgData = UIImageJPEGRepresentation(image, 0.2)!
            imageRef.put(imgData, metadata: metaData, completion: { (metadata, error) in
                
                if error == nil{
                    
                    let message = Message(text: "", username: self.senderDisplayName, senderId: self.senderId, mediaType: "Image", mediaUrl: String(describing: metadata!.downloadURL()!))
                    let messageRef = databaseRef.child("chatrooms").child(self.chatRoomId).child("messages").childByAutoId()
                    
                    messageRef.setValue(message.toAny(), withCompletionBlock: { (error, ref) in
                        
                        if error == nil{
                            //Para setear el lastMessage de la conversacion en firebase
                            let lastMessageRef = databaseRef.child("chatrooms").child(self.chatRoomId).child("lastMessage")
                            lastMessageRef.setValue("Image", withCompletionBlock: { (error, ref) in
                                
                                if error == nil{
                                    //Para notificar al ChatListVC sobre el cambio en lastMessage
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateChats"), object: nil)
                                    
                                }else{
                                    print(error!.localizedDescription)
                                }
                            })
                            
                            //Para setear el timestamp del ultimo mensaje en firebase
                            let timestampRef = databaseRef.child("chatrooms").child(self.chatRoomId).child("timestamp")
                            timestampRef.setValue(NSDate().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                                
                                if error == nil{
                                    
                                    
                                }else{
                                    print(error!.localizedDescription)
                                }
                            })
                            
                            //Que haya un sonido cuando mando un mesaje
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.finishSendingMessage()
                            
                        }else{
                            print(error!.localizedDescription)
                        }
                    })
                }else{
                    print(error!.localizedDescription)
                }
            })
        }else{
            
            let videoPath = "messageWithMedia\(chatRoomId + NSUUID().uuidString)/video.mp4"
            let videoRef = storageRef.child(videoPath)
            
            let metaData = FIRStorageMetadata()
            metaData.contentType = "vide0/mp4"
            
            let videoUrl = NSData(contentsOf: withVideo!)
            videoRef.put(videoUrl as! Data, metadata: metaData, completion: { (metadata, error) in
                
                if error == nil{
                    
                    let message = Message(text: "", username: self.senderDisplayName, senderId: self.senderId, mediaType: "Video", mediaUrl: String(describing: metadata!.downloadURL()!))
                    let messageRef = databaseRef.child("chatrooms").child(self.chatRoomId).child("messages").childByAutoId()
                    
                    messageRef.setValue(message.toAny(), withCompletionBlock: { (error, ref) in
                        
                        if error == nil{
                            //Para setear el lastMessage de la conversacion en firebase
                            let lastMessageRef = databaseRef.child("chatrooms").child(self.chatRoomId).child("lastMessage")
                            lastMessageRef.setValue("Video", withCompletionBlock: { (error, ref) in
                                
                                if error == nil{
                                    //Para notificar al ChatListVC sobre el cambio en lastMessage
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateChats"), object: nil)
                                    
                                }else{
                                    print(error!.localizedDescription)
                                }
                            })
                            
                            //Para setear el timestamp del ultimo mensaje en firebase
                            let timestampRef = databaseRef.child("chatrooms").child(self.chatRoomId).child("timestamp")
                            timestampRef.setValue(NSDate().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                                
                                if error == nil{
                                    
                                    
                                }else{
                                    print(error!.localizedDescription)
                                }
                            })
                            
                            //Que haya un sonido cuando mando un mesaje
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.finishSendingMessage()
                            
                        }else{
                            print(error!.localizedDescription)
                        }
                    })
                }else{
                    print(error!.localizedDescription)
                }
            })
            
            
        }
        
        
        
    }
    
    private func getMedia(mediaType: CFString){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        if mediaType == kUTTypeImage{
            
            imagePicker.mediaTypes = [mediaType as String]
            
        }else if mediaType == kUTTypeMovie{
            
            imagePicker.mediaTypes = [mediaType as String]
        }
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    //MARK: ImagePicker Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            self.saveMediaMessage(withImage: picture, withVideo: nil)
            
        }else if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            
            self.saveMediaMessage(withImage: nil, withVideo: videoUrl)
        }
        
        self.dismiss(animated: true) { 
            //JSQSystemSoundPlayer.jsq_playMessageSentSound()
            //self.finishSendingMessage()

        }
        
    }
}

