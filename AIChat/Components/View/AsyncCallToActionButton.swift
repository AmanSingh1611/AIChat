//
//  AsyncCallToActionButton.swift
//  AIChat
//
//  Created by Aman on 24/03/26.
//

import SwiftUI

struct AsyncCallToActionButton: View {
    var title: String = "Finish"
    var isLoading: Bool = false
    var action: (() -> Void)
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(title)
            }
        }
        .callToActionButton()
        .anyButton {
            action()
        }
        .disabled(isLoading)
    }
}

#Preview {
    @Previewable @State var isLoading: Bool = false
    
    AsyncCallToActionButton(
        title: "Submit",
        isLoading: isLoading,
        action: {
            isLoading = true
            Task {
                try? await Task.sleep(for: .seconds(3))
                isLoading = false
            }
        }
    )
}
