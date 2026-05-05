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
    @Environment(LogManager.self) private var logManager
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
        .screenAppearAnalytics(name: "ChatView")
        .showCustomAlert(type: .confirmationDialog, alert: $showChatSettings)
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
        logManager.trackEvent(event: Event.loadChatStart)
        
        do {
            let userId = try authManager.getAuthId()
            chat = try await chatManager.getChat(userId: userId, avatarId: avatarId)
            logManager.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            logManager.trackEvent(event: Event.loadChatFail(error: error))
        }
    }
    
    private func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        return chat.id
    }
    
    func listenForChatMessages() async {
        logManager.trackEvent(event: Event.loadMessagesStart)
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
            } catch {
                logManager.trackEvent(event: Event.loadMessagesFail(error: error))
            }
        }
    }
    
    private func loadCurrentUser() {
        currentUser = userManager.currentUser
    }
    
    private func loadAvatar() async {
        logManager.trackEvent(event: Event.loadAvatarStart)
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            logManager.trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))

            self.avatar = avatar
            
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
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
                logManager.trackEvent(event: Event.messageSeenFail(error: error))
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
        logManager.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
        
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
                logManager.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: message))
                
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
                logManager.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: newAIMessage))
                
                // Upload AI Chat
                try await chatManager.addChatMessage(chatId: chat.id, message: newAIMessage)
                logManager.trackEvent(event: Event.sendMessageResponseSent(chat: chat, avatar: avatar, message: newAIMessage))
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.sendMessageFail(error: error))
            }
            isGeneratingResponse = false
        }
    }
    
    enum ChatViewError: LocalizedError {
        case noChat
    }
    
    private func createNewChat(userId: String) async throws -> ChatModel {
        logManager.trackEvent(event: Event.createChatStart)
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
        logManager.trackEvent(event: Event.chatSettingsPressed)
        
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
        logManager.trackEvent(event: Event.reportChatStart)
        
        Task {
            do {
                let chatId = try getChatId()
                let userId = try authManager.getAuthId()
                try await chatManager.reportChat(chatId: chatId, userId: userId)
                logManager.trackEvent(event: Event.reportChatSuccess)
                
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.reportChatFail(error: error))
                
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "We will review the chat shortly. You may leave the chat at any time. Thanks for bringing this to our attention!"
                )
            }
        }
    }
    
    private func onDeleteChatPressed() {
        logManager.trackEvent(event: Event.deleteChatStart)
        
        Task {
            do {
                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
                logManager.trackEvent(event: Event.deleteChatSuccess)
                
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.deleteChatFail(error: error))
                
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection."
                )
            }
        }
    }
    
    private func onAvatarImagePressed() {
        logManager.trackEvent(event: Event.avatarImagePressed(avatar: avatar))
        
        showProfileModal = true
    }
    
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess(avatar: AvatarModel?)
        case loadAvatarFail(error: Error)
        case loadChatStart
        case loadChatSuccess(chat: ChatModel?)
        case loadChatFail(error: Error)
        case loadMessagesStart
        case loadMessagesFail(error: Error)
        case messageSeenFail(error: Error)
        case sendMessageStart(chat: ChatModel?, avatar: AvatarModel?)
        case sendMessageFail(error: Error)
        case sendMessageSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponse(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponseSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case createChatStart
        case chatSettingsPressed
        case reportChatStart
        case reportChatSuccess
        case reportChatFail(error: Error)
        case deleteChatStart
        case deleteChatSuccess
        case deleteChatFail(error: Error)
        case avatarImagePressed(avatar: AvatarModel?)

        var eventName: String {
            switch self {
            case .loadAvatarStart:          return "ChatView_LoadAvatar_Start"
            case .loadAvatarSuccess:        return "ChatView_LoadAvatar_Success"
            case .loadAvatarFail:           return "ChatView_LoadAvatar_Fail"
            case .loadChatStart:            return "ChatView_LoadChat_Start"
            case .loadChatSuccess:          return "ChatView_LoadChat_Success"
            case .loadChatFail:             return "ChatView_LoadChat_Fail"
            case .loadMessagesStart:        return "ChatView_LoadMessages_Start"
            case .loadMessagesFail:         return "ChatView_LoadMessages_Fail"
            case .messageSeenFail:          return "ChatView_MessageSeen_Fail"
            case .sendMessageStart:         return "ChatView_SendMessage_Start"
            case .sendMessageFail:          return "ChatView_SendMessage_Fail"
            case .sendMessageSent:          return "ChatView_SendMessage_Sent"
            case .sendMessageResponse:      return "ChatView_SendMessage_Response"
            case .sendMessageResponseSent:  return "ChatView_SendMessage_ResponseSent"
            case .createChatStart:          return "ChatView_CreateChat_Start"
            case .chatSettingsPressed:      return "ChatView_ChatSettings_Pressed"
            case .reportChatStart:          return "ChatView_ReportChat_Start"
            case .reportChatSuccess:        return "ChatView_ReportChat_Success"
            case .reportChatFail:           return "ChatView_ReportChat_Fail"
            case .deleteChatStart:          return "ChatView_DeleteChat_Start"
            case .deleteChatSuccess:        return "ChatView_DeleteChat_Success"
            case .deleteChatFail:           return "ChatView_DeleteChat_Fail"
            case .avatarImagePressed:       return "ChatView_AvatarImage_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarFail(error: let error), .loadChatFail(error: let error), .loadMessagesFail(error: let error), .messageSeenFail(error: let error), .sendMessageFail(error: let error), .reportChatFail(error: let error), .deleteChatFail(error: let error):
                return error.eventParameters
            case .loadAvatarSuccess(avatar: let avatar), .avatarImagePressed(avatar: let avatar):
                return avatar?.eventParameters
            case .loadChatSuccess(chat: let chat):
                return chat?.eventParameters
            case .sendMessageStart(chat: let chat, avatar: let avatar):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                return dict
            case .sendMessageSent(chat: let chat, avatar: let avatar, message: let message),
                .sendMessageResponse(chat: let chat, avatar: let avatar, message: let message),
                .sendMessageResponseSent(chat: let chat, avatar: let avatar, message: let message):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                dict.merge(message.eventParameters)
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadChatFail, .sendMessageFail:
                return .warning
            case .loadAvatarFail, .loadMessagesFail, .messageSeenFail, .reportChatFail, .deleteChatFail:
                return .severe
            default:
                return .analytic
            }
        }
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
