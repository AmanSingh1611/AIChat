//
//  Collection+EXT.swift
//  AIChat
//
//  Created by Aman on 22/04/26.
//

extension Collection {
    func first(upto value: Int) -> [Element]? {
        guard !self.isEmpty else {return nil}
        
        let maxItems = Swift.min(self.count, value)
        
        return Array(self.prefix(maxItems))
    }
    
    func last(upto value: Int) -> [Element]? {
        guard !self.isEmpty else {return nil}
        
        let maxItems = Swift.min(self.count, value)
        
        return Array(self.suffix(maxItems))
    }
}
