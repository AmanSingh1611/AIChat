//
//  ChatService.swift
//  AIChat
//
//  Created by Aman on 24/04/26.
//
import SwiftUI

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
        
    }
}

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: ChatService {
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }

    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
}
