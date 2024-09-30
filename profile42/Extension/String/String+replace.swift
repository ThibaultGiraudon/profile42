//
//  String+replace.swift
//  profile42
//
//  Created by Thibault Giraudon on 30/09/2024.
//

import SwiftUI

extension String {
    func replace(_ target: String, with replacement: String) -> String {
        return replacingOccurrences(of: target, with: replacement, options: .literal, range: nil)
    }
}
