//
//  AIService.swift
//  AIChat
//
//  Created by Aman on 16/04/26.
//
import SwiftUI

protocol AIService: Sendable {
    func generateImage(input: String) async throws -> UIImage
}
