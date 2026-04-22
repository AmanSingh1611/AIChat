//
//  AvatarManager.swift
//  AIChat
//
//  Created by Aman on 17/04/26.
//

import SwiftUI

protocol AvatarService {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseAvatarService: AvatarService {
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        // Upload Image
        let path = "avatar/\(avatar.avatarId)"
        let url = try await MockImageUploadService().uploadImage(image: image, path: path)
        
        // Upload the avatar image name
        var avatar = avatar
        avatar.updateProfileImageName(imageName: url.absoluteString)
        
        // Upload the avatar
        try collection.document(avatar.avatarId).setData(from: avatar, merge: true)
        
    }
}

struct MockAvatarService: AvatarService {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        
    }
}

@MainActor
@Observable
class AvatarManager {
    private let service: AvatarService
    
    init(service: AvatarService) {
        self.service = service
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await service.createAvatar(avatar: avatar, image: image)
    }
}
