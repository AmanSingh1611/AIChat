//
//  Error+EXT.swift
//  AIChat
//
//  Created by Aman Kumar Singh on 03/05/26.
//

import Foundation

extension Error {
    
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}
