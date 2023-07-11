//
//  ModuleList.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 07.06.2023.
//

import SwiftUI

struct SearchResult: Codable {
    let objects: [Object]
    let total: Int
    let time: String
}

struct Object: Codable {
    let package: Package
    let flags: Flags?
    let score: Score
    let searchScore: Double
}

struct Flags: Codable {
    let unstable: Bool
}

struct Package: Codable {
    let name: String
    let scope: String
    let version: String
    let author: Author?
    let description: String?
    let keywords: [String]?
    let date: String
    let links: Links
    let publisher: Publisher
    let maintainers: [Maintainer]
}

struct Author: Codable {
    let name: String
    let email: String?
    let url: String?
    let username: String?
}

struct Links: Codable {
    let npm: String
    let homepage, repository, bugs: String?
}

struct Publisher: Codable {
    let username: String
    let email: String
}

struct Maintainer: Codable {
    let username: String
    let email: String
}

struct Score: Codable {
    let final: Double
    let detail: Detail
}

struct Detail: Codable {
    let quality, popularity, maintenance: Double
}

struct ModuleList: View {
    @State var favouriteModules: [Object]? = nil
    @State var searchModules: [Object]? = nil
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var isSearching: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .frame(height: 300)
                } else {
                    if isSearching {
                        if searchModules?.isEmpty == false {
                            ScrollView {
                                ForEach(searchModules!.indices, id: \.self) { index in
                                    NavigationLink(destination: ModuleDetail(moduleName: searchModules![index].package.name)) {
                                        Text(searchModules![index].package.name)
                                        Spacer()
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if index != searchModules!.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        } else {
                            Text("No modules found")
                                .padding()
                            
                        }
                    } else {
                        if favouriteModules?.isEmpty == false {
                            ScrollView {
                                ForEach(favouriteModules!.indices, id: \.self) { index in
                                    NavigationLink(destination: ModuleDetail(moduleName: favouriteModules![index].package.name)) {
                                        ModuleRow(module: favouriteModules![index].package)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if index != favouriteModules!.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        } else {
                            Text("No modules found")
                                .padding()
                        }
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle("Modules")
            .onAppear {
                loadData(newVal: "noction") { modules in
                    favouriteModules = modules
                }
            }
            .padding(20)
            .onChange(of: searchText) { newVal in
                isSearching = !newVal.isEmpty
                loadData(newVal: newVal) { modules in
                    searchModules = modules
                }
            }
        }
        .searchable(text: $searchText)
    }

    
    func loadData(newVal: String = "noction", completion: @escaping ([Object]?) -> Void) {
        let text = newVal.isEmpty || newVal.count < 2 ? "noction" : newVal
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://registry.npmjs.org/-/v1/search?text=\(encodedText)&size=20"
        
        guard let url = URL(string: urlString) else {
            print("Your API end point is Invalid")
            completion(nil)
            return
        }
        let request = URLRequest(url: url)
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            isLoading = false
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("Data is nil")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                let response = try decoder.decode(SearchResult.self, from: data)
                completion(response.objects)
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

}

struct ModuleList_Previews: PreviewProvider {
    static var previews: some View {
        ModuleList()
    }
}
