//
//  ChatView.swift
//  AIChat
//
//  Created by Aman on 24/03/26.
//

import SwiftUI

struct ChatView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    @Environment(ChatManager.self) private var chatManager
    
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel?
    @State private var chat: ChatModel?
    @State private var textMessage: String = ""
    @State private var scrollPosition: String?
    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?
    @State private var showProfileModal: Bool = false
    @State private var isGeneratingResponse: Bool = false
    
    var avatarId: String = AvatarModel.mock.avatarId
    
    var body: some View {
        VStack(spacing: 0) {
            scrollSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                HStack {
                    if isGeneratingResponse {
                        ProgressView()
                    }
                    
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .foregroundStyle(.accent)
                        .anyButton {
                            onChatSettingsPressed()
                        }
                }
            }
        }
        .showCustomAlert(type: .confirmationDialogue, alert: $showChatSettings)
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $showProfileModal) {
            if let avatar {
                profileModal(avatar: avatar)
            }
        }
        .task {
            await loadAvatar()
        }
        .onAppear {
            loadCurrentUser()
        }
    }
    
    private func loadCurrentUser() {
        currentUser = userManager.currentUser
    }
    
    private func loadAvatar() async {
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            self.avatar = avatar
            
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            print("Error loading avatar \(error)")
        }
    }
    
    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.description,
            onXMarkPressed: {
                showProfileModal = false
            }
        )
        .padding(40)
        .transition(.slide)
    }
    
    private var scrollSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorId == authManager.userAuth?.uid
                    
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onAvatarImagePressed
                    )
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180))
        }
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: scrollPosition)
        
    }
    
    private var textFieldSection: some View {
        TextField("Say Something...", text: $textMessage)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 50)
            .overlay(
                alignment: .trailing,
                content: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .padding(4)
                        .foregroundStyle(.accent)
                        .anyButton {
                            onSendMessagePressed()
                        }
                }
            )
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(uiColor: .systemBackground))
                    
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(.gray.opacity(0.3), lineWidth: 1)
                }
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Color(.secondarySystemBackground)
                    .ignoresSafeArea()
            }
    }
    
    private func onSendMessagePressed() {
        
        let content = textMessage
        
        Task {
            do {
                // Get user id
                let userId = try authManager.getAuthId()
                
                // Validate text field text
                try TextValidationHelper.checkIfTextIsValid(text: content)
                
                // If chat is nil then create a new chat
                if chat == nil {
                    chat = try await createNewChat(userId: userId)
                }
                
                // If there is no chat, throw error (should never happen)
                guard let chat else {
                    throw ChatViewError.noChat
                }
                
                // Create user chat
                let newMessage = AIChatModel(role: .user, content: content)
                let message = ChatMessageModel.newUserMessage(chatId: chat.id, userId: userId, message: newMessage)
                
                // Upload user chat
                try await chatManager.addChatMessage(chatId: chat.id, message: message)
                chatMessages.append(message)
                
                // Clear text field and scroll to bottom
                scrollPosition = message.id
                textMessage = ""
                
                // Generate AI response
                isGeneratingResponse = true
                let aiChats = chatMessages.compactMap({ $0.content })
                let response = try await aiManager.generateText(chats: aiChats)
                
                
                //Create AI Chat
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chat.id, avatarId: avatarId, message: response)
                
                // Upload AI Chat
                try await chatManager.addChatMessage(chatId: chat.id, message: newAIMessage)
                chatMessages.append(newAIMessage)
                scrollPosition = newAIMessage.id
                
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
            isGeneratingResponse = false
        }
    }
    
    enum ChatViewError: LocalizedError {
        case noChat
    }
    
    private func createNewChat(userId: String) async throws -> ChatModel {
        let newChat = ChatModel.new(userId: userId, avatarId: avatarId)
        try await chatManager.createNewChat(chat: newChat)
        return newChat
    }
    
    private func onChatSettingsPressed() {
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User/Chat", role: .destructive) {
                            
                        }
                        
                        Button("Delete Chat", role: .destructive) {
                            
                        }
                    }
                )
            }
        )
    }
    
    private func onAvatarImagePressed() {
        showProfileModal = true
    }
}

#Preview("Working Chat") {
    NavigationStack {
        ChatView()
            .previewEnvironment()
    }
}

#Preview("Slow AI Generation") {
    NavigationStack {
        ChatView()
            .environment(AIManager(imageGenerationService: MockAIService(delay: 5), textGenerationService: MockAIService(delay: 5)))
            .previewEnvironment()
    }
}

#Preview("Failed AI Generation") {
    NavigationStack {
        ChatView()
            .environment(AIManager(imageGenerationService: MockAIService(delay: 5), textGenerationService: MockAIService(delay: 5, showError: true)))
            .previewEnvironment()
    }
}
