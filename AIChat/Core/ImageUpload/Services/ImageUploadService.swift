//
//  ImageUploadService.swift
//  AIChat
//
//  Created by Aman on 23/04/26.
//
import SwiftUI

protocol ImageUploadService {
    func uploadImage(image: UIImage, path: String) async throws -> URL
}
