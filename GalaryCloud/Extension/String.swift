//
//  String.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import Foundation

extension String {
    
    func extractSubstring(key:String, key2:String) -> String? {
        let pattern = "<\(key)>(.*?)<\(key2)>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            
                return nil
            }
            
            let range = NSRange(self.startIndex..<self.endIndex, in: self)
        if let match = regex.firstMatch(in: self, options: [], range: range) {
                
                let rangeStart = match.range(at: 1)
                if let swiftRange = Range(rangeStart, in: self) {
                    return String(self[swiftRange])
                }
            }
        
        return nil
    }
    
    var addSpaceBeforeCapitalizedLetters: String {
        let regex = try? NSRegularExpression(pattern: "(?<=\\w)(?=[A-Z])", options: [])
        let result = regex?.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count), withTemplate: " $0")
        return result ?? self
    }
}
