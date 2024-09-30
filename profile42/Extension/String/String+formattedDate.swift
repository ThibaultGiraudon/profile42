//
//  String+formattedDate.swift
//  profile42
//
//  Created by Thibault Giraudon on 30/09/2024.
//

import SwiftUI

extension String {
    func formattedDate(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        let strFormatter = DateFormatter()
        strFormatter.dateFormat = format
        return strFormatter.string(from: dateFormatter.date(from: self) ?? Date())
    }
}
