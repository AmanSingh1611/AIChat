//
//  MockImageUploadService.swift
//  AIChat
//
//  Created by Aman on 21/04/26.
//
import UIKit

struct MockImageUploadService: ImageUploadService {
    func uploadImage(image: UIImage, path: String) async throws -> URL {
        try? await Task.sleep(for: .seconds(1))
        guard let url = URL(string: Constants.randomImage) else {
            throw URLError(.badURL)
        }
        return url
    }
}
