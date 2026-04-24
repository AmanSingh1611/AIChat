//
//  FirebaseAvatarService.swift
//  AIChat
//
//  Created by Aman on 22/04/26.
//
import FirebaseFirestore
import SwiftfulFirestore
import UIKit

struct FirebaseAvatarService: RemoteAvatarService {
    
    let imageUploadService: ImageUploadService
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        try await collection.document(avatarId).updateData([
            AvatarModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
        ])
    }
    
    func getAvatarForAuthor(userId: String) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .order(by: AvatarModel.CodingKeys.dateCreated.rawValue, descending: true)
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
            .order(by: AvatarModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        let path = "avatar/\(avatar.avatarId)"
        let url = try await imageUploadService.uploadImage(image: image, path: path)
        
        var avatar = avatar
        avatar.updateProfileImageName(imageName: url.absoluteString)
        
        try collection.document(avatar.avatarId).setData(from: avatar, merge: true)
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await collection.document(avatarId).updateData([
            AvatarModel.CodingKeys.authorId.rawValue: NSNull()
        ])
    }
    
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws {
        let avatars = try await getAvatarForAuthor(userId: userId)
        
        try await withThrowingTaskGroup(returning: Void.self) { group in
            for avatar in avatars {
                group.addTask {
                    try await removeAuthorIdFromAvatar(avatarId: avatar.id)
                }
            }
            try await group.waitForAll()
        }
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await collection.getDocument(id: id)
    }
}
