//
//  FavouriteStorageViewModel.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 10.07.2023.
//

import Foundation

class FavoriteStorageViewModel: ObservableObject {
    private let myKey = "favoriteModules"
    
    @Published var myList: [String] {
        didSet {
            UserDefaults.standard.set(myList, forKey: myKey)
        }
    }
    
    init() {
        self.myList = UserDefaults.standard.stringArray(forKey: myKey) ?? []
    }
    
    func set(items: [String]) {
        myList = items
    }
    
    func add(item: String) {
        if !myList.contains(item) {
            myList.append(item)
        }
    }
    
    func remove(item: String) {
        myList.removeAll { $0 == item }
    }
    
    func clear() {
        myList = []
    }
    
    func isFavorite(name: String) -> Bool {
        return myList.contains(name)
    }
}
