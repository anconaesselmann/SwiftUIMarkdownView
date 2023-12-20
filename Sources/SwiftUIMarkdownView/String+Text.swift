//  Created by Axel Ancona Esselmann on 12/20/23.
//

import SwiftUI

extension String {
    func interpolatedText() -> Text? {
        let separator = "🐈🐅🦭🚲"
        let regex = #/\{([^\:]+)\:([^\}]+)\}/#
        let items = self
            .replacing(regex) { match in
                separator + "{\(match.1):\(match.2)}" + separator
            }
            .split(separator: separator)
            .map {
                if
                    let match = $0.firstMatch(of: regex),
                    String(match.1) == "systemName"
                {
                    return Text(Image(systemName: String(match.2)))
                } else {
                    return Text(LocalizedStringKey(String($0)))
                }
            }
        var result = Text("")
        guard items.count > 1 else {
            return nil
        }
        for item in items {
            result = result + item
        }
        return result
    }
}
