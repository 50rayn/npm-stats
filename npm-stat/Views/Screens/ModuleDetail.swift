//
//  ModuleDetail.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 07.06.2023.
//

import SwiftUI

struct NodePoint: Codable {
    let downloads: Int
    let day: String
    
    init(day: String, downloads: Int) {
        self.day = day
        self.downloads = downloads
    }
}

struct NodeEntry: Codable {
    let start: String
    let end: String
    let package: String
    let downloads: [NodePoint]
}

struct ModuleInfo: Decodable, Equatable {
    let name: String
    let description: String?
    //    let homepage: URL?
    //    let repository: Repository?
    let maintainers: [Maintainer]
    let keywords: [String]?
    var readme: String
    //    let license: String?
    let version: String?
    //    let versions: [String: String]?
    //    let dependencies: [String: String]?
    //    let devDependencies: [String: String]?
    //    let bugs: Bugs?
    //    let contributors: [Contributor]?
    //    let author: Author?
    //    let users: [String]?
    //    let time: Time?
    //    let distTags: [String: String]?
    //
    //
    //    struct Time: Codable {
    //        let created: String?
    //        let modified: String?
    //    }
    //
    //    struct Repository: Codable {
    //        let type: String
    //        let url: URL
    //    }
    //
    struct Maintainer: Codable, Equatable {
        let name: String
        let email: String?
    }
    //
    //    struct Bugs: Codable {
    //        let url: URL?
    //        let email: String?
    //    }
    //
    //    struct Contributor: Codable {
    //        let name: String
    //        let email: String?
    //        let url: URL?
    //    }
    //
    //    enum Author: Codable {
    //        case string(String)
    //        case object(AuthorObject)
    //    }
    //
    //    struct AuthorObject: Codable {
    //        let name: String
    //        let email: String?
    //        let url: URL?
    //    }
}

struct ModuleDetail: View {
    let packageName: String
    @EnvironmentObject var favourites: FavoriteStorageViewModel
    @State var period: String
    @StateObject var chartVM: ChartViewModel = ChartViewModel()
    @State var isLoading: Bool = false
    @State var moduleInfo: ModuleInfo? = nil
    @State var readme: String? = nil
    @State private var selectedTab: Int = 0
    @State private var isLoadingMarkdown: Bool = true
    
    
    
    init(packageName: String) {
        self.packageName = packageName
        self.period = "last-month"
        chartVM.selectedRange = .oneWeek
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                OverviewView(
                    moduleInfo: $moduleInfo,
                    chartVM: chartVM,
                    period: $period
                )
                .tag(0)
                
                ModuleDetailReadme(
                    readme: $readme,
                    isLoadingMarkdown: $isLoadingMarkdown)
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
            .background(.clear)
            .padding(.horizontal, 16)
            
            
            VStack {
                VStack{
                    Picker("", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Readme").tag(1)
                    }
                    .padding(16)
                    .pickerStyle(SegmentedPickerStyle())
                    .animation(.easeInOut, value: selectedTab)
                    .background(.ultraThinMaterial)
                }
                
                Spacer()
                
            }
            .background(.clear)
            .navigationTitle(packageName)
            .navigationBarTitleDisplayMode(.inline)
            .task(id: chartVM.selectedRange) {
                await chartVM.fetchData(packageName: packageName)
            }
            .onAppear {
                fetchModuleDetail()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        addModuleToFavorites()
                    }) {
                        if favourites.isFavorite(name: packageName) == true {
                            Image(systemName: "heart.fill")
                        } else {
                            Image(systemName: "heart")
                        }
                    }
                }
            }
        }
        .onChange(of: moduleInfo) { newValue in
            readme = newValue?.readme
        }
    }
    
    private func addModuleToFavorites() {
        if favourites.isFavorite(name: packageName) == true {
            favourites.remove(item: packageName)
        } else {
            favourites.add(item: packageName)
        }
    }
    
    private func fetchModuleDetail() {
        let urlString = "https://registry.npmjs.org/\(packageName)"
        
        guard let url = URL(string: urlString) else {
            print("Your API end point is Invalid")
            isLoadingMarkdown = false // stop loading state in case of error
            return
        }
        
        let request = URLRequest(url: url)
        isLoadingMarkdown = true // start loading state
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                isLoadingMarkdown = false // stop loading state in case of error
                return
            }
            
            guard let data = data else {
                print("Data is nil")
                isLoadingMarkdown = false // stop loading state in case of error
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                let response = try decoder.decode(ModuleInfo.self, from: data)
                DispatchQueue.main.async {
                    moduleInfo = response
                    isLoadingMarkdown = false // stop loading state on success
                }
            } catch {
                print("Decoding error module detail: \(error.localizedDescription)")
                isLoadingMarkdown = false // stop loading state in case of error
            }
        }.resume()
    }
}


struct ModuleDetail_Previews: PreviewProvider {
    static var previews: some View {
        let packageName = "@noction/vue-highcharts"
        
        return AnyView(ModuleDetail(packageName: packageName)
            .environmentObject(FavoriteStorageViewModel())
            .previewLayout(.fixed(width: 300, height: 70)))
    }
}

