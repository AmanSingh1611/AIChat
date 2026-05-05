//
//  RemoteUserService.swift
//  AIChat
//
//  Created by Aman on 16/04/26.
//

protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func addListener(to userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
}
