//
//  String+-.swift
//  profile42
//
//  Created by Thibault Giraudon on 30/09/2024.
//

import SwiftUI

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
