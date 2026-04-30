//
//  Array+EXT.swift
//  AIChat
//
//  Created by Aman on 30/04/26.
//

import Foundation

extension Array {
    func sortedByKeyPath<T: Comparable>(keyPath: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        self.sorted { item1, item2 in
            let value1 = item1[keyPath: keyPath]
            let value2 = item2[keyPath: keyPath]
            return ascending ? (value1 < value2) : (value1 > value2)
        }
    }
    
    mutating func sortedByKeyPath<T: Comparable>(keyPath: KeyPath<Element, T>, ascending: Bool = true) {
        self.sort { item1, item2 in
            let value1 = item1[keyPath: keyPath]
            let value2 = item2[keyPath: keyPath]
            return ascending ? (value1 < value2) : (value1 > value2)
        }
    }
}
