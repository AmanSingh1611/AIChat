//
//  ChatsListingView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

struct ChatsListingView: View {
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AuthManager.self) private var authManager
    
    @State private var chats: [ChatModel] = []
    @State private var recentAvatars: [AvatarModel] = []
    @State private var path: [NavigationPathOption] = []
    @State private var isLoadingChats: Bool = true
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                }

                chatsSection
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $path)
            .onAppear {
                loadRecentAvatars()
            }
            .task {
                await loadChatsListing()
            }
        }
    }
    
    private func loadChatsListing() async {
        do {
            let userId = try authManager.getAuthId()
            chats = try await chatManager.getAllChats(userId: userId).sortedByKeyPath(keyPath: \.dateModified, ascending: false)
        } catch {
            print("Failed to load chats")
        }
        
        isLoadingChats = false
    }
    
    private func loadRecentAvatars() {
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
        } catch {
            print("Failed to load recents")
        }
    }
    
    private var chatsSection: some View {
        Section {
            if isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
            } else if chats.isEmpty {
                Text("Your chats will appear here!")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: authManager.userAuth?.uid,
                        chat: chat,
                        getAvatar: {
                            try? await avatarManager.getAvatar(id: chat.avatarId)
                        },
                        getLastChatMessage: {
                            try? await chatManager.getLastChatMessage(chatId: chat.id)
                        }
                    )
                    .anyButton(.highlight, action: {
                        onChatPressed(chat: chat)
                    })
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text(chats.isEmpty ? "" : "Chats")
        }
    }
    
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .anyButton {
                                onAvatarPressed(avatar: avatar)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
            .frame(height: 120)
            .scrollIndicators(.hidden)
            .removeListRowFormatting()
        } header: {
            Text("Recents")
        }
    }
    
    private func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
}

#Preview("Has data") {
    ChatsListingView()
        .previewEnvironment()
}
#Preview("No data") {
    ChatsListingView()
        .environment(
            AvatarManager(
                service: MockRemoteAvatarService(avatars: []),
                local: MockLocalAvatarPersistence(avatars: [])
            )
        )
        .environment(ChatManager(service: MockChatService(chats: [])))
        .previewEnvironment()
}
#Preview("Slow loading chats") {
    ChatsListingView()
        .environment(ChatManager(service: MockChatService(delay: 5)))
        .previewEnvironment()
}
