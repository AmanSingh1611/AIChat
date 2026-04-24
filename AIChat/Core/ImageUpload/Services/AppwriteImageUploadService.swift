//
//  AppwriteImageUploadService.swift
//  AIChat
//
//  Created by Aman on 23/04/26.
//

import UIKit
import Appwrite

struct AppwriteImageUploadService: ImageUploadService {
    
    private let client: Client
    private let storage: Appwrite.Storage
    private let bucketId = AppwriteConstants.appwriteBucketId
    private let projectId = AppwriteConstants.appwriteProjectId
    
    init(client: Client = Client()
        .setEndpoint(AppwriteConstants.appwriteURL)
        .setProject(AppwriteConstants.appwriteProjectId)
    ) {
        self.client = client
        self.storage = Storage(client)
    }
    
    func uploadImage(image: UIImage, path: String) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw URLError(.badURL)
        }
        
        let fileName = "\(path).jpg"
        
        let result = try await storage.createFile(
            bucketId: bucketId,
            fileId: ID.unique(),
            file: InputFile.fromData(
                data,
                filename: fileName,
                mimeType: "image/jpeg"
            ),
            permissions: [
                Permission.read(Role.any()),
                Permission.write(Role.any())
            ]
        )
        
        guard let url = URL(string: fileViewURL(fileId: result.id)) else {
            throw URLError(.badURL)
        }
        
        return url
    }
    
    private func fileViewURL(fileId: String) -> String {
        return "\(client.endPoint)/storage/buckets/\(bucketId)/files/\(fileId)/view?project=\(projectId)"
    }
}
