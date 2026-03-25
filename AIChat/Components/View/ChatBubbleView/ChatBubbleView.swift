//
//  ChatBubbleView.swift
//  AIChat
//
//  Created by Aman on 24/03/26.
//

import SwiftUI

struct ChatBubbleView: View {
    var textColor: Color = .primary
    var backgroundColor: Color = Color(uiColor: .systemGray6)
    var text: String = "This is a message string!!"
    var imageName: String?
    var showImage: Bool = true
    let offset: CGFloat = 10
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showImage {
                ZStack {
                    if let imageName {
                        ImageLoaderView(urlString: imageName)
                    } else {
                      Rectangle()
                            .fill(.secondary)
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .offset(y: offset)
            }
            
            Text(text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .cornerRadius(10)
        }
        .padding(.bottom, showImage ? offset : 0)
    }
}

#Preview {
    //ChatBubbleView 10:00
    ScrollView {
        VStack(spacing: 16) {
            ChatBubbleView()
            ChatBubbleView(
                textColor: .primary,
                text: "This is a verylarge text.This is a verylarge text.This is a verylarge text.This is a verylarge text.This is a verylarge text.This is a verylarge text.This is a verylarge text."
            )
            ChatBubbleView(
                textColor: .white,
                backgroundColor: .accent,
                imageName: nil,
                showImage: false
            )
            
            ChatBubbleView(
                textColor: .white,
                backgroundColor: .accent,
                text: "This is a verylarge text.This is a verylarge text.This is a verylarge text.This is a verylarge text.This is a verylarge text.This is a verylarge text.This is a verylarge text.",
                imageName: nil,
                showImage: false
            )
        }
        .padding(8)
    }
}
