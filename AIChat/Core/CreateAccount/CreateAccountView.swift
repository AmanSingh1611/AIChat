//
//  CreateAccountView.swift
//  AIChat
//
//  Created by Aman on 24/03/26.
//

import SwiftUI
import AuthenticationServices

struct CreateAccountView: View {
    var title: String = "Create Account?"
    var subTitle: String = "Don't lose your data! connect to an SSO provider to save your account"
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text(subTitle)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 55)
            .anyButton(.press) {
                
            }
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
    }
}

#Preview {
    CreateAccountView()
}
