//
//  npm_statApp.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 06.06.2023.
//

import SwiftUI

@main
struct npm_statApp: App {
    @StateObject private var favourites = FavoriteStorageViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favourites)
        }
    }
}
