//  Created by Axel Ancona Esselmann on 12/15/23.
//

import Splash
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension Theme {
    // Xcode Dark theme
    static func xcodeColors(withFont font: Splash.Font) -> Theme {
        return Theme(
            font: font,
            plainTextColor: Colors.plainTextColor,
            tokenColors: [
                .keyword: Colors.keyword,
                .string: Colors.string,
                .type: Colors.type,
                .call: Colors.call,
                .number: Colors.number,
                .comment: Colors.comment,
                .property: Colors.property,
                .dotAccess: Colors.dotAccess,
                .preprocessing: Colors.preprocessing
            ],
            backgroundColor: Colors.backgroundColor
        )
    }
}
