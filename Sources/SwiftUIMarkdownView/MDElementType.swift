//  Created by Axel Ancona Esselmann on 12/14/23.
//

import Foundation

public enum MDElementType: Hashable {
    case header(Int)
    case text
    case listItem
    case image
    case rule
    case lineBreak
    case frame
    case codeBlock
}
