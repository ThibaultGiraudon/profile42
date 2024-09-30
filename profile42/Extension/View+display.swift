//
//  View+display.swift
//  profile42
//
//  Created by Thibault Giraudon on 26/09/2024.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func display(_ display: Bool) -> some View {
        if display {
            self
        } else {
            EmptyView()
        }
    }
}
