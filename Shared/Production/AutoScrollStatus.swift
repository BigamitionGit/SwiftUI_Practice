//
//  AutoScrollStatus.swift
//  SwiftUI_Practice (iOS)
//
//  Created by hosoda-hiroshi on 2022/05/24.
//

import Foundation
import SwiftUI

public enum AutoScrollStatus {
    case inactive
    case active(TimeInterval)
}


extension AutoScrollStatus {
    
    /// Is the view auto-scrolling
    var isActive: Bool {
        switch self {
        case .active(let t): return t > 0
        case .inactive : return false
        }
    }
    
    /// Duration of automatic scrolling
    var interval: TimeInterval {
        switch self {
        case .active(let t): return t
        case .inactive : return 0
        }
    }
}
