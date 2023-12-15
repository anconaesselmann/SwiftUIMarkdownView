//  Created by Axel Ancona Esselmann on 12/15/23.
//

import Splash
import AppKit
public typealias Color = NSColor

internal extension Color {
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

public extension Theme {
    // Xcode Dark theme
    static func xcodeColors(withFont font: Splash.Font) -> Theme {
        return Theme(
            font: font,
            plainTextColor: Color(
                red: 223.0 / 255.0,
                green: 223.0 / 255.0,
                blue: 224.0 / 255.0
            ),
            tokenColors: [
                .keyword: Color(red: 238.0 / 255.0, green: 131.0 / 255.0, blue: 176.0 / 255.0),
                .string: Color(red: 239.0 / 255.0, green: 136.0 / 255.0, blue: 118.0 / 255.0),
                .type: Color(red: 186.0 / 255.0, green: 240.0 / 255.0, blue: 227.0 / 255.0),
                .call: Color(red: 104.0 / 255.0, green: 174.0 / 255.0, blue: 201.0 / 255.0),
                .number: Color(red: 215.0 / 255.0, green: 201.0 / 255.0, blue: 134.0 / 255.0),
                .comment: Color(red: 129.0 / 255.0, green: 140.0 / 255.0, blue: 150.0 / 255.0),
                .property: Color(red: 137.0 / 255.0, green: 192.0 / 255.0, blue: 180.0 / 255.0),
                .dotAccess: Color(red: 170.0 / 255.0, green: 133.0 / 255.0, blue: 228.0 / 255.0),
                .preprocessing: Color(red: 242.0 / 255.0, green: 164.0 / 255.0, blue: 95.0 / 255.0)
            ],
            backgroundColor: Color(
                red: 0.098,
                green: 0.098,
                blue: 0.098
            )
        )
    }
}
