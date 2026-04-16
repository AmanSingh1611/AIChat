//
//  LocalUserPersistence.swift
//  AIChat
//
//  Created by Aman on 16/04/26.
//

protocol LocalUserPersistence {
    func getCurrentUser() -> UserModel?
    
    func saveCurrentUser(user: UserModel?) throws
}
