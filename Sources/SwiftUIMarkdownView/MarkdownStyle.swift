//  Created by Axel Ancona Esselmann on 12/14/23.
//

import Foundation

public struct MarkdownStyle {
    public var linkConversionRules: [any LinkConversionRule]
    public var dataProvider: (any MDDataProvider)?
    public var elementStyles: [MDElementType: MDElementStyle]

    public init(
        linkConversionRules: [any LinkConversionRule] = [],
        dataProvider: (any MDDataProvider)? = nil,
        elementStyles: [MDElementType : MDElementStyle] = [:]
    ) {
        self.linkConversionRules = linkConversionRules
        self.dataProvider = dataProvider
        self.elementStyles = elementStyles
    }
}
