//  Created by Axel Ancona Esselmann on 12/14/23.
//

import Foundation

public struct MDElementStyle {
    public enum Padding: Hashable {
        case leading(Double)
        case trailing(Double)
        case top(Double)
        case bottom(Double)
        case vertical(Double)
        case horizontal(Double)
    }

    public let padding: Set<Padding>

    public init(padding: Set<Padding>) {
        self.padding = padding
    }
}
