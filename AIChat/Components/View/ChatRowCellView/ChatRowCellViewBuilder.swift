//
//  ChatRowCellViewBuilder.swift
//  AIChat
//
//  Created by Aman on 07/03/26.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    var currentUserId: String?
    var chat: ChatModel = .mock
    var getAvatar: () async -> AvatarModel?
    var getLastChatMessage: () async -> ChatMessageModel?
    
    @State private var avatar: AvatarModel?
    @State private var lastChatMessage: ChatMessageModel?
    
    @State private var didLoadAvatar: Bool = false
    @State private var didLoadChatMessage: Bool = false
    
    private var isLoading: Bool {
        if didLoadAvatar && didLoadChatMessage {
            return false
        }
        return true
    }
    
    private var hasNewChat: Bool {
        guard let currentUserId, let lastChatMessage else { return false }
        return lastChatMessage.hasBeenSeenBy(userId: currentUserId)
    }
    
    private var subheadline: String? {
        if isLoading {
            return "xxxx xxxx xxxx"
        }
        
        if avatar == nil && lastChatMessage == nil {
            return "Error"
        }
        
        return lastChatMessage?.content
    }
    
    var body: some View {
        ChatRowCellView(
            imageName: avatar?.profileImageName,
            headline: isLoading ? "xxxx xxxx" : avatar?.name,
            subheadline: subheadline,
            hasNewChat: isLoading ? false : hasNewChat
        )
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            avatar = await getAvatar()
            didLoadAvatar = true
        }
        .task {
            lastChatMessage = await getLastChatMessage()
            didLoadChatMessage = true
        }
    }
}

#Preview {
    VStack {
        ChatRowCellViewBuilder(currentUserId: nil, chat: .mock, getAvatar: {
            try? await Task.sleep(for: .seconds(5))
            return .mock
        }, getLastChatMessage: {
            try? await Task.sleep(for: .seconds(5))
            return .mock
        })
        
        ChatRowCellViewBuilder(currentUserId: nil, chat: .mock, getAvatar: {
            return .mock
        }, getLastChatMessage: {
            return .mock
        })
        
        ChatRowCellViewBuilder(currentUserId: nil, chat: .mock, getAvatar: {
            return nil
        }, getLastChatMessage: {
            return nil
        })
    }
}
