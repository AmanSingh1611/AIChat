//
//  ChatBubbleViewBuilder.swift
//  AIChat
//
//  Created by Aman on 25/03/26.
//

import SwiftUI

struct ChatBubbleViewBuilder: View {
    var message: ChatMessageModel = .mock
    var isCurrentUser: Bool = false
    var imageName: String?
    
    var body: some View {
        ChatBubbleView(
            textColor: isCurrentUser ? .white : .primary,
            backgroundColor: isCurrentUser ? .accent : Color(uiColor: .systemGray6),
            text: message.content ?? "",
            imageName: imageName,
            showImage: !isCurrentUser
        )
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(.leading, isCurrentUser ? 75 : 0)
        .padding(.trailing, isCurrentUser ? 0 : 75)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(isCurrentUser: true)
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: UUID().uuidString,
                    content: "This is a long text that goes to multiple line and keeps on goin to multiple line goes on and on and on .",
                    seenByIds: nil,
                    dateCreated: .now
                )
            )
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: UUID().uuidString,
                    content: "This is a long text that goes to multiple line and keeps on goin to multiple line goes on and on and on .",
                    seenByIds: nil,
                    dateCreated: .now
                ),
                isCurrentUser: true
            )
            
        }
        .padding(12)
    }
}
