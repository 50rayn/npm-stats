//
//  SearchModules.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 10.07.2023.
//

import SwiftUI

struct SearchResponse: Decodable {
    let objects: [ObjectItem]
}

struct ObjectItem: Codable {
    let package: SearchItemInfo
}

struct SearchItemInfo: Codable {
    let name: String
    let description: String?
    let version: String
}

struct SearchModules<Content: View>: View {
    @Environment(\.isSearching) var isSearching
    @EnvironmentObject var favourites: FavoriteStorageViewModel
    @State var searchModules: [ObjectItem]? = nil
    @State private var searchTimer: Timer? = nil // Add a search timer
    @State private var isFetching: Bool = false
    var queryString: String
    let customView: () -> Content // 2
    
    init(queryString: String, @ViewBuilder customView: @escaping () -> Content) {
        self.queryString = queryString
        self.customView = customView
    }
    
    var body: some View {
        VStack {
            if isSearching {
                if isFetching {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        Text("Loading...")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else if let searchModules = searchModules, !searchModules.isEmpty {
                    ScrollView {
                        ForEach(searchModules.indices, id: \.self) { index in
                            NavigationLink(
                                destination: ModuleDetail(packageName: searchModules[index].package.name)
                            ) {
                                SearchItem(
                                    title: searchModules[index].package.name,
                                    subtitle: searchModules[index].package.description ?? ""
                                )
                                Spacer()
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if index != searchModules.count - 1 {
                                Divider()
                            }
                        }
                    }
                } else {
                    Text("No results found")
                        .foregroundColor(.secondary)
                        .padding()
                }
            } else {
                customView()
            }
        }
        .animation(.easeInOut, value: isSearching)
        .onChange(of: queryString) { newVal in
            if newVal.isEmpty {
                searchModules = nil
            } else {
                searchTimer?.invalidate()
                searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    loadData(newVal: newVal) { modules in
                        searchModules = modules
                    }
                }
            }
        }
    }
    
    func loadData(newVal: String, completion: @escaping ([ObjectItem]?) -> Void) {
        isFetching = true
        
        let text = newVal.trimmingCharacters(in: .whitespacesAndNewlines)
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://registry.npmjs.org/-/v1/search?text=\(encodedText)&size=20"
        
        guard let url = URL(string: urlString) else {
            print("Invalid API endpoint URL")
            completion(nil)
            isFetching = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                isFetching = false
                return
            }
            
            guard let data = data else {
                print("Data is nil")
                completion(nil)
                isFetching = false
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SearchResponse.self, from: data)
                completion(response.objects)
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(nil)
            }
            isFetching = false
        }
        
        task.resume()
    }
}

struct SearchModules_Previews: PreviewProvider {
    static var previews: some View {
        SearchModules(queryString: "@noction") {
            Text("Not searching")
        }
    }
}
