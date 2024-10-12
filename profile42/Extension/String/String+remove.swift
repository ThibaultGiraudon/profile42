//
//  String+remove.swift
//  profile42
//
//  Created by Thibault Giraudon on 12/10/2024.
//

import SwiftUI

extension String {
    func remove(nsRange: NSRange) -> String {
        guard let range = Range(nsRange, in: self) else { return self }
        
        let prefix = self[..<range.lowerBound]
        let suffix = self[range.upperBound...]
        
        return String(prefix) + String(suffix)
    }
}
