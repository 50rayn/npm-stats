//
//  ModuleDetail.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 07.06.2023.
//

import MarkdownUI
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

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

struct ModuleInfo: Decodable {
    let name: String
//    let description: String?
//    let homepage: URL?
//    let repository: Repository?
//    let maintainers: [Maintainer]
//    let keywords: [String]?
    let readme: String
//    let license: String?
//    let version: String?
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
//    struct Maintainer: Codable {
//        let name: String
//        let email: String?
//    }
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
    var module: Package
    let packageName: String
    @State var results: NodeEntry? = nil
    @State var period: String = "last-week"
    @StateObject var chartVM: ChartViewModel = ChartViewModel()
    @State var isLoading: Bool = false
    @State var moduleInfo: ModuleInfo? = nil
    @State private var selectedTab: Int = 0
    @State private var isLoadingMarkdown: Bool = true
    
    init(module: Package) {
        self.module = module
        self.packageName = module.name
        self.period = "last-week"
        chartVM.selectedRange = .oneWeek
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                overviewView
                    .tag(0)
                readmeView
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3))
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
                        .animation(.easeInOut) // Apply animation to the picker
                        .background(.ultraThinMaterial)
                    }

                    Spacer()

                }
                .background(.clear)
                .navigationTitle(module.name)
                .navigationBarTitleDisplayMode(.inline)
                .task(id: chartVM.selectedRange) {
                    await chartVM.fetchData(packageName: packageName)
                }
                .onAppear {
                    fetchModuleDetail()
                }
                
            
        }
    }

    private var overviewView: some View {
        ScrollView {
            Spacer(minLength: 76)
            VStack(alignment: .leading, spacing: 20) {
                scrollView
                
                Text(module.description ?? "")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Version")
                        .font(.headline)
                    
                    Text(module.version)
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Package Details")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(title: "Scope", value: module.scope)
                        if let keywords = module.keywords {
                            DetailRow(title: "Keywords", value: keywords.joined(separator: ", "))
                        }
                        DetailRow(title: "Publisher", value: module.publisher.username)
                        DetailRow(title: "Maintainers", value: module.maintainers.map { $0.username }.joined(separator: ", "))
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private var readmeView: some View {
        ScrollView {
            Spacer(minLength: 76)
            Group {
                if isLoadingMarkdown {
                    LoadingStateView() // Show loading indicator
                } else {
                    ScrollView {
                        Markdown(moduleInfo?.readme ?? "")
                    }
                }
            }
            .onAppear {
                fetchModuleDetail()
            }
        }
    }
    
    private var scrollView: some View {
        VStack {
            ZStack {
                    DateRangePickerView(
                        selectedRange: $chartVM.selectedRange,
                        selectedTitle: $period
                    )
              }
            
            chartView
                .frame(maxWidth: .infinity, minHeight: 220)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.none)
    }
    
    @ViewBuilder
    private var chartView: some View {
        switch chartVM.fetchPhase {
            case .fetching: LoadingStateView()
            case .success(let data):
                ChartView(data: data, vm: chartVM)
            case .failure(let error):
                ErrorStateView(error: "Chart: \(error.localizedDescription)")
            default: EmptyView()
        }
    }
    
    private func fetchModuleDetail() {
        let urlString = "https://registry.npmjs.org/\(packageName)"
        
        guard let url = URL(string: urlString) else {
            print("Your API end point is Invalid")
            return
        }
        
        let request = URLRequest(url: url)
        
        isLoadingMarkdown = true
        
        isLoadingMarkdown = false
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                
                return
            }
            
            guard let data = data else {
                print("Data is nil")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                let response = try decoder.decode(ModuleInfo.self, from: data)
                DispatchQueue.main.async {
                    moduleInfo = response
                    isLoadingMarkdown = false // Set loading state to false after data is fetched
                }
            } catch {
                print("Decoding error module detail: \(error.localizedDescription)")
            }
        }.resume()
    }
}


struct ModuleDetail_Previews: PreviewProvider {
    static var previews: some View {
        let packageData = """
        {
            "name": "@noction/vue-highcharts",
            "scope": "noction",
            "version": "1.0.2",
            "description": "Vue wrapper for Highcharts",
            "keywords": [
                "vue-highcharts",
                "highcharts-vue",
                "highcharts",
                "vue-charts",
                "wrapper",
                "vue",
                "component",
                "charts",
                "vue3"
            ],
            "date": "2023-05-07T18:52:17.307Z",
            "links": {
                "npm": "https://www.npmjs.com/package/%40noction%2Fvue-highcharts",
                "homepage": "https://github.com/Noction/vue-highcharts",
                "repository": "https://github.com/Noction/vue-highcharts",
                "bugs": "https://github.com/Noction/vue-highcharts/issues"
            },
            "publisher": {
                "username": "lwvemike",
                "email": "plamadeala.mihai002@gmail.com"
            },
            "maintainers": [
                {
                    "username": "lwvemike",
                    "email": "plamadeala.mihai002@gmail.com"
                },
                {
                    "username": "50rayn",
                    "email": "soryngitlan@gmail.com"
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        do {
            let package = try decoder.decode(Package.self, from: packageData)
            return AnyView(ModuleDetail(module: package)
                .previewLayout(.fixed(width: 300, height: 70)))
        } catch {
            print("Error decoding package:", error)
            return AnyView(Text("Error: \(error.localizedDescription)"))
        }

    }
}

