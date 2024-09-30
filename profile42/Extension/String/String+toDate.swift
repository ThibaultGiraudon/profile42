//
//  String+toDate.swift
//  profile42
//
//  Created by Thibault Giraudon on 30/09/2024.
//

import SwiftUI

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.date(from: self) ?? Date()
    }
}
