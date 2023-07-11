//
//  Home.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 23.06.2023.
//

import SwiftUI

struct Home: View {
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            SearchModules(queryString: searchText) {
                List {
                    Section {
                        Favorites()
                    } header: {
                        Text("Favorites")
                    }
                }
            }
            .navigationBarTitle("Home")
            .listStyle(.insetGrouped)
        }
        .searchable(text: $searchText)
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
