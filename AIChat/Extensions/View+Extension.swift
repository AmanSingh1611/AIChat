//
//  View+Extension.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import Foundation
import SwiftUI

extension View {
    func callToActionButton() -> some View {
        self
        .font(.headline)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background(.accent)
        .cornerRadius(16)
    }
    
    func tapablebackground() -> some View {
        self.background(Color.black.opacity(0.001))
    }
    
    func removeListRowFormatting() -> some View {
        self
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    func adddingGradientBackgroundForText() -> some View {
        self
        .background(
            LinearGradient(colors: [
                Color.black.opacity(0),
                Color.black.opacity(0.3),
                Color.black.opacity(0.4)
            ], startPoint: .top, endPoint: .bottom)
        )
    }
}
