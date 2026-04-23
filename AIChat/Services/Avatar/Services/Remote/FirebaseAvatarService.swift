//
//  FirebaseAvatarService.swift
//  AIChat
//
//  Created by Aman on 22/04/26.
//

import FirebaseFirestore
import SwiftfulFirestore
import Appwrite

struct FirebaseAvatarService: RemoteAvatarService {
    func getAvatarForAuthor(userId: String) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .getAllDocuments()
    }
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.characterOption.rawValue, isEqualTo: category.rawValue)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await collection
            .limit(to: 50)
            .getAllDocuments()
            .shuffled()
            .first(upto: 5) ?? []
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await collection
            .limit(to: 200)
            .getAllDocuments()
    }
    
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        // Upload Image
        let path = "avatar/\(avatar.avatarId)"
        let client = Client()
            .setEndpoint("https://nyc.cloud.appwrite.io/v1")
            .setProject("69e9b65200207791909e")
        
        let uploader = AppwriteImageUploadService(client: client)
        
        let url = try await uploader.uploadImage(image: image, path: path)
        
        // Upload the avatar image name
        var avatar = avatar
        avatar.updateProfileImageName(imageName: url.absoluteString)
        
        // Upload the avatar
        try collection.document(avatar.avatarId).setData(from: avatar, merge: true)
        
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await collection.getDocument(id: id)
    }
}
