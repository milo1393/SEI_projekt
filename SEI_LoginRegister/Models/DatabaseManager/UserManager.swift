//
//  UserManager.swift
//  SEI_LoginRegister
//
//  Created by Marko Milosavljevic on 26.06.21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserManager {
    
    static let shared = UserManager() //to make it singelton
    private let db = Firestore.firestore()
    
}

// MARK: - Firebase
extension UserManager {
    
    //checks if User (Email) is already in Firestore
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)){
        let docRef = db.collection("user").document(email)
        docRef.getDocument { (document, error) in
            guard let doc = document, error == nil else {
                print("Error in DatabaseManager userExists Method: \(String(describing: error?.localizedDescription))")
                return
            }
            completion(doc.exists)
        }
    }
    
    /// Inserts new User to the Database
    public func insertUser(with user: User, completion: @escaping((Bool) -> Void)){
        
        guard let userId = user.userID else {
            completion(false)
            return
        }
        do {
            try db.collection("users").document(userId).setData(from: user)
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    func getUser(userID: String, completion: @escaping(_ user: User?) -> ()) {
        let docRef = db.collection("users").document(userID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let result = Result { try document.data(as: User.self)}
                switch result {
                case .success(let user):
                    if let user = user {
                        completion(user)
                    }
                case .failure(let error):
                    print("Error casting User: \(error)")
                    completion(nil)
                }
            } else {
                print("User not found!")
                completion(nil)
            }
        }
    }
}


// MARK: - User Defaults
extension UserManager {
    
    func setUserDefaults(currentUser: User, completion: @escaping(_ success: Bool) -> ()) {
    
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do{
            let data = try encoder.encode(currentUser.getUserDefaultUser())
            if let json = String(data: data, encoding: .utf8)  {
                UserDefaults.standard.set(json, forKey: "currentUser")
                completion(true)
            } else {
                completion(false)
            }
            
        } catch {
            print(error)
        }
    }
    
    /// Store current User in UserDefault
    public func getUserDefault() -> User?{
        
        do{
            if let json = UserDefaults.standard.object(forKey: "currentUser") as? String {
                let data = json.data(using: .utf8)!
                let decoder = JSONDecoder()
                let user = try decoder.decode(User.UserDefaultUser.self, from: data)
                return user.getUser()
            }
            return nil
        }
        catch{
            return nil
        }
    }
}
