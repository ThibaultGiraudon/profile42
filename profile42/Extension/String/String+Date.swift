//
//  String+Date.swift
//  profile42
//
//  Created by Thibault Giraudon on 30/09/2024.
//

import SwiftUI

extension String {
    func getDay() -> String {
        let stripped = self.dropFirst(8)
        return String(stripped.prefix(2))
    }
    
    func getMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        let strFormatter = DateFormatter()
        strFormatter.dateFormat = "MMM"
        return strFormatter.string(from: dateFormatter.date(from: self) ?? Date())
    }
    
    func getHour() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        let strFormatter = DateFormatter()
        strFormatter.dateFormat = "HH:mm"
        return strFormatter.string(from: dateFormatter.date(from: self) ?? Date())
        
    }
}
