//  Created by Axel Ancona Esselmann on 12/14/23.
//

import Foundation

public protocol MDDataProvider {
    func value(for key: String) -> String?
}
