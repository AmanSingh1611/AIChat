//
//  ModalSupportView.swift
//  AIChat
//
//  Created by Aman on 09/04/26.
//

import SwiftUI

struct ModalSupportView<Content: View>: View {
    @Binding var showModal: Bool
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack {
            if showModal {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(AnyTransition.opacity.animation(.smooth))
                    .onTapGesture {
                        showModal = false
                    }
                    .zIndex(1)
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .zIndex(2)
            }
        }
        .zIndex(999)
        .animation(.bouncy, value: showModal)
    }
}
struct PreviewView: View {
    @State private var showModal = false
    
    var body: some View {
        Button("Click Me") {
            showModal = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .showModal(showModal: $showModal) {
            Text("Hi")
        }
    }
}

extension View {
    func showModal(showModal: Binding<Bool>, @ViewBuilder content: () -> some View) -> some View {
        self
            .overlay {
                ModalSupportView(showModal: showModal) {
                    content()
                }
            }
    }
}

#Preview {
    PreviewView()
}
