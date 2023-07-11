//
//  Module.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 07.06.2023.
//

import Foundation
import SwiftUI
import CoreLocation

struct Module: Identifiable {
    var id = UUID()
    let name: String
    
    init(name: String) {
        self.name = name
    }
}
