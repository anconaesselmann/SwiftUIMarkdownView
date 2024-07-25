//  Created by Axel Ancona Esselmann on 12/15/23.
//

import Foundation

import SwiftUI

#if os(macOS)
import AppKit

struct Colors {
    static let plainTextColor = NSColor(named: "XCDefault.plainTextColor", bundle: Bundle.module)!
    static let keyword = NSColor(named: "XCDefault.keyword", bundle: Bundle.module)!
    static let string = NSColor(named: "XCDefault.string", bundle: Bundle.module)!
    static let type = NSColor(named: "XCDefault.type", bundle: Bundle.module)!
    static let call = NSColor(named: "XCDefault.call", bundle: Bundle.module)!
    static let number = NSColor(named: "XCDefault.number", bundle: Bundle.module)!
    static let comment = NSColor(named: "XCDefault.comment", bundle: Bundle.module)!
    static let property = NSColor(named: "XCDefault.property", bundle: Bundle.module)!
    static let dotAccess = NSColor(named: "XCDefault.dotAccess", bundle: Bundle.module)!
    static let preprocessing = NSColor(named: "XCDefault.preprocessing", bundle: Bundle.module)!
    static let backgroundColor: NSColor = .black
}
#else
import UIKit

struct Colors {
    static let plainTextColor = UIColor(named: "XCDefault.plainTextColor", in: .module, compatibleWith: nil)!
    static let keyword = UIColor(named: "XCDefault.keyword", in: .module, compatibleWith: nil)!
    static let string = UIColor(named: "XCDefault.string", in: .module, compatibleWith: nil)!
    static let type = UIColor(named: "XCDefault.type", in: .module, compatibleWith: nil)!
    static let call = UIColor(named: "XCDefault.call", in: .module, compatibleWith: nil)!
    static let number = UIColor(named: "XCDefault.number", in: .module, compatibleWith: nil)!
    static let comment = UIColor(named: "XCDefault.comment", in: .module, compatibleWith: nil)!
    static let property = UIColor(named: "XCDefault.property", in: .module, compatibleWith: nil)!
    static let dotAccess = UIColor(named: "XCDefault.dotAccess", in: .module, compatibleWith: nil)!
    static let preprocessing = UIColor(named: "XCDefault.preprocessing", in: .module, compatibleWith: nil)!
    static let backgroundColor: UIColor = .white
}
#endif

