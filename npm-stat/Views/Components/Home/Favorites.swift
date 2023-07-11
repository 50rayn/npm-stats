//
//  Favorite.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 10.07.2023.
//

import SwiftUI

struct Favorites: View {
    @EnvironmentObject var favourites: FavoriteStorageViewModel
    
    var body: some View {
        if favourites.myList.isEmpty {
            Text("No modules found")
                .padding()
        } else {
            ForEach(favourites.myList, id: \.self) { item in
                NavigationLink(destination: ModuleDetail(moduleName: item)) {
                    Text(item)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct Favorites_Previews: PreviewProvider {
    static var previews: some View {        
        return Favorites()
    }
}
