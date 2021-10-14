//
//  ProfileViewModel.swift
//  InstagramClone
//
//  Created by David Malicke on 10/14/21.
//

import SwiftUI
import Firebase

class ProfileViewModel: ObservableObject {
    
    @Published var user: User
    
    init(user: User) {
        self.user = user
        
    }
    
    func changeProfileImage(image: UIImage, completion: @escaping(String) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.5 ) else { return }
        
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        ref.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            ref.downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                //downloads previously uploaded image into profileimage for user
                guard let imageURL = url?.absoluteString else { return }
                
                guard let uid = self.user.id else {return}
                
                Firestore.firestore().collection("users").document(uid).updateData(["profileImageURL": imageURL]) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    
}
