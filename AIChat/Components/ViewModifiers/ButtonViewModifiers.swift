//
//  ButtonViewModifiers.swift
//  AIChat
//
//  Created by Aman on 06/03/26.
//

import Foundation
import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                configuration.isPressed ? Color.accent.opacity(0.4) : Color.accent.opacity(0)
            }
            .animation(.smooth, value: configuration.isPressed)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.smooth, value: configuration.isPressed)
    }
}

enum ButtonStyleOption {
    case highlight, press, plain
}

extension View {
    
    @ViewBuilder
    func anyButton(_ option: ButtonStyleOption = .plain, action: @escaping () -> Void) -> some View {
        switch option {
        case .highlight:
            self.highlightButton(action: action)
        case .press:
            self.pressableButton(action: action)
        case .plain:
            self.plainButton(action: action)
        }
    }
    
    private func highlightButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(CustomButtonStyle())
    }
    
    private func pressableButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PressableButtonStyle())
    }
    
    private func plainButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PlainButtonStyle())
    }
}
#Preview {
    VStack {
        Text("Button")
            .padding()
            .frame(maxWidth: .infinity)
            .tappablebackground()
            .anyButton(.highlight, action: {
                
            })
            .padding()
        
        Text("Button")
            .callToActionButton()
            .anyButton(.press, action: {
                
            })
            .padding()
        
        Text("Button")
            .callToActionButton()
            .anyButton(.plain, action: {
                
            })
            .padding()
        
    }
    
}
