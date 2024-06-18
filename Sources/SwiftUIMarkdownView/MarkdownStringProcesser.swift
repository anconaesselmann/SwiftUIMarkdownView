//  Created by Axel Ancona Esselmann on 12/10/23.
//

import Foundation

public extension String {
    mutating func mapLink(_ predicate: (String) -> String) {
        replace(#/\[([^\]]+)\]\(([^\)]+)\)/#) { match in
            "[\(match.output.1)](\(predicate(String(match.output.2))))"
        }
    }

    func mdImage(_ predicate: (String) -> MDImageStyle?) -> MDImage? {
        if
            let result = try? #/!\[([^\]]+)\]\(([^\)]+)\)/#.firstMatch(in: self),
            let url = URL(string: String(result.output.2))
        {
            let style = predicate(String(result.output.2))
            return MDImage(altText: String(result.output.1), url: url, style: style)
        } else {
            return nil
        }
    }

    func mdImage(using conversionRules: [any ImageConversionRule]) -> MDImage? {
        mdImage {
            for rule in conversionRules {
                if rule.matches($0) {
                    return rule.map($0)
                }
            }
            return nil
        }
    }

    mutating func mapLink(using conversionRules: [any LinkConversionRule]) {
        mapLink {
            for rule in conversionRules {
                if rule.matches($0) {
                    return rule.map($0)
                }
            }
            return $0
        }
    }

    mutating func mapLink(using conversionRules: (any LinkConversionRule)...) {
        mapLink(using: conversionRules)
    }

    mutating func insertData(using dataProvider: any MDDataProvider) {
        replace(#/\{([^\}^\:]+)\}/#) { match in
            let key = String(match.output.1)
            guard let value = dataProvider.value(for: key) else {
                return "MISSING VALUE FOR KEY \(key)"
            }
            return value
        }
    }

    // https://www.hackingwithswift.com/example-code/strings/how-to-remove-a-prefix-from-a-string
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

public protocol LinkConversionRule {
    func matches(_ string: String) -> Bool
    func map(_ string: String) -> String
}

public protocol ImageConversionRule {
    func matches(_ string: String) -> Bool
    func map(_ string: String) -> MDImageStyle
}
