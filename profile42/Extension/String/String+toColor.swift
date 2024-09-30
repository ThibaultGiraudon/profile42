//
//  String+toColor.swift
//  profile42
//
//  Created by Thibault Giraudon on 30/09/2024.
//

import SwiftUI

extension String {
    func toColor() -> Color {
        var color: Color = .cyan
        var colorString: String = self
        if self.contains("#") {
            colorString.removeFirst()
            var colorList: [String] = []
            while colorString.count > 0 {
                let chars = colorString.prefix(2)
                if chars.count == 2 {
                    colorList.append(String(chars))
                    colorString.removeFirst(2)
                } else {
                    return color
                }
            }
            if colorList.count != 3 {
                return color
            }
            let red = Int(colorList[0], radix: 16) ?? 0
            let green = Int(colorList[1], radix: 16) ?? 0
            let blue = Int(colorList[2], radix: 16) ?? 0
            color = Color(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
        }
        return color
    }
}
