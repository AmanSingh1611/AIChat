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
    @Environment(\.dismiss) private var dismiss
    
    @State private var chatMessages: [ChatMessageModel] = []
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel?
    @State var chat: ChatModel?
    @State private var textMessage: String = ""
    @State private var scrollPosition: String?
    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?
    @State private var showProfileModal: Bool = false
    @State private var isGeneratingResponse: Bool = false
    @State private var messageListener: Task<Void, Never>?
    
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
        .task {
            await loadChat()
            await listenForChatMessages()
        }
        .onAppear {
            loadCurrentUser()
        }
        .onDisappear {
            messageListener?.cancel()
        }
    }
    
    private func loadChat() async {
        do {
            let userId = try authManager.getAuthId()
            chat = try await chatManager.getChat(userId: userId, avatarId: avatarId)
            print("Success loading chat.")
        } catch {
            print("Error loading chat.")
        }
    }
    
    private func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        return chat.id
    }
    
    func listenForChatMessages() async {
        messageListener?.cancel()
        
        messageListener = Task {
            do {
                let chatId = try self.getChatId()
                
                for try await value in self.chatManager.streamChatMessages(chatId: chatId) {
                    if Task.isCancelled { break }
                    
                    let sortedMessages = value.sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                    
                    await MainActor.run {
                        self.chatMessages = sortedMessages
                        self.scrollPosition = sortedMessages.last?.id
                    }
                }
            } catch is CancellationError {
                print("Chat message listener cancelled")
            } catch {
                print("Chat view failed to attach listener: \(error)")
            }
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

                    if messageIsDelayed(message: message) {
                        timeStampView(date: message.dateCreatedCalculated)
                    }
                     
                    let isCurrentUser = message.authorId == authManager.userAuth?.uid
                    
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onAvatarImagePressed
                    )
                    .onAppear {
                        onMessageDidAppear(message: message)
                    }
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
    
    private func onMessageDidAppear(message: ChatMessageModel) {
        Task {
            do {
                let userId = try authManager.getAuthId()
                let chatId = try getChatId()
                guard !message.hasBeenSeenBy(userId: userId) else {
                    return
                }
                try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: message.id, userId: userId)
            } catch {
                print("Failed to mark as seen.")
            }
        }
    }
    
    private func messageIsDelayed(message: ChatMessageModel) -> Bool {
        guard let index = chatMessages.firstIndex(where: { $0.id == message.id }) else {
            return false
        }
        
        if index == 0 {
            return true
        }
        
        let currentDate = chatMessages[index].dateCreatedCalculated
        let previousDate = chatMessages[index - 1].dateCreatedCalculated
        
        // Threshold = 60 seconds * 45 minutes
        let threshold: TimeInterval = 60 * 45
        return currentDate.timeIntervalSince(previousDate) > threshold
    }
    
    private func timeStampView(date: Date) -> some View {
        Text(
            "\(date.formatted(date: .abbreviated, time: .omitted)) • \(date.formatted(date: .omitted, time: .shortened))"
        )
        .foregroundStyle(.secondary)
        .font(.callout)
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
                
                // Clear text field and scroll to bottom
                textMessage = ""
                
                // Generate AI response
                isGeneratingResponse = true
                var aiChats = chatMessages.compactMap({ $0.content })
                if let avatarDescription = avatar?.description {
                    // Description "A cat smiliing in the park"
                    let systemMessage = AIChatModel(
                        role: .system,
                        content: "You are a \(avatarDescription) with the inteligence of an AI. We are having a very casual conversation. You are my friend."
                    )
                    aiChats.insert(systemMessage, at: 0)
                }
                let response = try await aiManager.generateText(chats: aiChats)
                
                // Create AI Chat
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chat.id, avatarId: avatarId, message: response)
                
                // Upload AI Chat
                try await chatManager.addChatMessage(chatId: chat.id, message: newAIMessage)
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
        defer {
            Task {
                await listenForChatMessages()
            }
        }
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
                            onReportChatPressed()
                        }
                        
                        Button("Delete Chat", role: .destructive) {
                            onDeleteChatPressed()
                        }
                    }
                )
            }
        )
    }
    
    private func onReportChatPressed() {
        Task {
            do {
                let chatId = try getChatId()
                let userId = try authManager.getAuthId()
                try await chatManager.reportChat(chatId: chatId, userId: userId)
                dismiss()
            } catch {
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "We will review the chat shortly. You may leave the chat at any time. Thanks for bringing this to our attention!"
                )
            }
        }
    }
    
    private func onDeleteChatPressed() {
        Task {
            do {
                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
                dismiss()
            } catch {
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection."
                )
            }
        }
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
