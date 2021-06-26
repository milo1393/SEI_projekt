//
//  User.swift
//  SEI_LoginRegister
//
//  Created by Marko Milosavljevic on 26.06.21.
//

import Foundation
import FirebaseFirestoreSwift

enum Gender: String, Codable {
    case MALE = "MALE"
    case FEMALE = "FEMALE"
}

struct User : Codable{
    @DocumentID var userID: String?
    let firstName: String
    let lastName: String
    let email: String
    let gender: Gender
    var profilePictureURL: String? //only if user has profilePicture set
    var name: String {
        return "\(firstName) \(lastName)"
    }
    
    public func getUserDefaultUser() -> UserDefaultUser {
        return UserDefaultUser(userID: self.userID, firstName: self.firstName, lastName: self.lastName, email: self.email, gender: self.gender, profilePictureURL: self.profilePictureURL)
    }
    
    
    //needed to store User in UserDefaults (could not get @DocumentID to Serialize)
    struct UserDefaultUser : Codable{
        var userID: String?
        let firstName: String
        let lastName: String
        let email: String
        let gender: Gender
        let profilePictureURL: String?
        
        public func getUser() -> User {
            return User(userID: self.userID, firstName: self.firstName, lastName: self.lastName, email: self.email, gender: self.gender, profilePictureURL: self.profilePictureURL)
        }
    }
}


