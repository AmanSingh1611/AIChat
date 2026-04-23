//
//  FirebaseImageUploadService.swift
//  AIChat
//
//  Created by Aman on 17/04/26.
//

import SwiftUI
import FirebaseStorage

struct FirebaseImageUploadService: ImageUploadService {
    func uploadImage(image: UIImage, path: String) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.dataNotAllowed)
        }
        
        let reference = imageReference(path: path)
        
        // Upload URL
        _ = try await saveImage(data: data, path: path)
        
        // Download URL
        return try await reference.downloadURL()
        
    }
    
    private func imageReference(path: String) -> StorageReference {
        let name = "\(path).jpg"
        return Storage.storage().reference(withPath: name)
    }
    
    private func saveImage(data: Data, path: String) async throws -> URL {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let returnedMeta = try await imageReference(path: path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMeta.path, let url = URL(string: returnedPath) else {
            throw URLError(.badServerResponse)
        }
        
        return url
    }
}
