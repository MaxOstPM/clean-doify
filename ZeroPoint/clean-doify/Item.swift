//
//  Item.swift
//  clean-doify
//
//  Created by Maksym Ostapchuk on 11/10/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
