//
//  ChatView.swift
//  AIChat
//
//  Created by Aman on 24/03/26.
//

import SwiftUI

struct ChatView: View {
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var avatar: AvatarModel? = .mock
    @State private var currentUser: UserModel? = .mock
    @State private var textMessage: String = ""
    @State private var scrollPosition: String?
    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?
    @State private var showProfileModal: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            scrollSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "Chat")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Image(systemName: "ellipsis")
                    .padding(8)
                    .foregroundStyle(.accent)
                    .anyButton {
                        onChatSettingsPressed()
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
                    let isCurrentUser = currentUser?.userId == message.authorId
                    
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
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
        guard let currentUser else {return}
        
        let content = textMessage
        
        do {
            try TextValidationHelper.checkIfTextIsValid(text: content)
            let message = ChatMessageModel(
                id: UUID().uuidString,
                chatId: UUID().uuidString,
                authorId: currentUser.userId,
                content: content,
                seenByIds: nil,
                dateCreated: .now
            )
            chatMessages.append(message)
            scrollPosition = message.id
            textMessage = ""
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
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

#Preview {
    NavigationStack {
        ChatView()
    }
}
