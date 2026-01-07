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
}
