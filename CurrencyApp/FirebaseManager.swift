//
//  FirebaseManager.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 25/11/22.
//

import Foundation

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

import ReactiveSwift

public enum UploadKind {
    case image
    case avatar
}

class FirebaseManager: NetworkManager {
    
    
    private let storage = Storage.storage(url: "gs://planets-image-bucket")
    private var currentUser: UserModel? = nil
    
    override init() {
        
        super.init()
        
    }
    
    public func setupUser(_ currentUser: UserModel) {
        self.currentUser = currentUser
        getAuthToken().on(value: { [weak self] token in
            Auth.auth().signIn(withCustomToken: token) { user, error in
                print("WE HAVE USER HERE", user)
                print("WE HAVE ERROR HERE", error)
            }
        }).start()
    }
    
    public func getAuthToken() -> STSignalProducer<String> {
        
        guard let currentUser = currentUser else { return .weakError }
        
        guard let url = URL(string: baseURL + FIREBASEAUTHURL) else { return  .weakError }
        var urlRequest = getRequest(type: "POST", url: url)
        do {
            urlRequest.httpBody = try JSONEncoder().encode( HTTPFirebaseModel.FirebaseAuthRequest(userID: currentUser.userID))
        } catch let error {
            print(error.localizedDescription)
            return .weakError
        }
        return request(with: urlRequest).flatMapLatest( { [weak self] tokenData -> STSignalProducer<String> in
            
            guard let me = self else {
                
                return .weakError }
            if let token = try? JSONDecoder().decode(HTTPFirebaseModel.FirebaseAuthResponse.self, from: tokenData) {
                return STSignalProducer(value: token.authToken)
            } else {
                return .weakError
            }
        })
    }
    
    public func uploadImage(image: UIImage, useCase: UploadKind) -> STSignalProducer<String> {
        guard let currentUser = currentUser else { return .weakError }
        return STSignalProducer { [weak self] observer, lifetime in
            guard let me = self else { return observer.sendWeakError()}
            
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let storageref = me.storage.reference()
            let imageNode: StorageReference
            switch useCase {
            case .avatar:
                imageNode = storageref.child(currentUser.userID).child("AVATAR").child("avatar.png")
            case .image:
                imageNode = storageref.child(currentUser.userID).child("UPLOADEDIMAGES").child(UUID().uuidString + ".png")
            }
            if let imageData = image.jpeg(.low) {
                let task = imageNode.putData(imageData, metadata: metadata)
                { [weak self] (metadata2, error) in
                    guard let metadata2 = metadata2 else {
                        observer.send(anyError: InternalError.unexpectedNil)
                        print("ERROR IS", error)
                        print("MEETA DATA IS", metadata2)
                        return
                    }
                    
                    print("META DATA GOAT IS", metadata2)
                    
                    imageNode.downloadURL(completion: { (url, error) in
                        if let urlText = url?.absoluteString {
                            
                            print("URL TEXT IS", urlText)
                            
                            
                            observer.send(value: urlText)
                            observer.sendCompleted()
                        }
                    })
                    
                }
                
                
                
                task.resume()
            }
            
            
        }.observe(on: QueueScheduler.main)
        
    }
    
}


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
