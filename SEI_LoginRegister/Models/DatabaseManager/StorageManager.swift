//
//  StorageManager.swift
//  SEI_LoginRegister
//
//  Created by Marko Milosavljevic on 26.06.21.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager() //to make it singelton
    private let storage = Storage.storage().reference()
}

// MARK: - Upload Images

extension StorageManager {
    
    /// Uploads picture to firebase storage and returns url string to download (path: /profile_images/user_id.png)
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        return uploadImage(data: data, path: "profile_images/\(fileName).png", completion: {result in
            completion(result)
        })
    }
    
    ///uploads images of the parking spots to spot_images/(spotID)/(index).jpg
    func uploadParkingSpotImages(images:[UIImage], spotID: String, completion: @escaping(Result<[String]?, Error>)->Void)
    {
        var urls: [String] = []
        images.enumerated().forEach { (index, image) in
            guard let data = image.jpegData(compressionQuality: 0.2) else {
                completion(.failure(StorageErrors.failedToConvert))
                return
            }
            
            uploadImage(data: data, path: "spot_images/\(spotID)/\(index).jpg", completion: { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let downloadUrl):
                    urls.append(downloadUrl)
                    if urls.count == images.count {
                        completion(.success(urls))
                    }
                }
            })
        }
    }
    
    private func uploadImage(data: Data, path: String, completion: @escaping (Result<String, Error>) -> Void){
       // Create a reference to the file you want to upload
       let riversRef = self.storage.child(path)
       
       // Upload the file to the path "images/rivers.jpg"
       _ = riversRef.putData(data, metadata: nil) { (metadata, error) in
           guard metadata != nil else {
               completion(.failure(StorageErrors.failedToUpload))
               return
           }
           riversRef.downloadURL { (url, error) in
               guard let downloadURL = url else {
                   completion(.failure(StorageErrors.failedToGetDownloadUrl))
                   return
               }
               completion(.success(downloadURL.absoluteString))
               return
           }
       }
       
   }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
        case failedToConvert
    }
}


