//
//  ChartViewModel.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 09.06.2023.
//

import Foundation
import Charts

@MainActor
class ChartViewModel: ObservableObject {
    @Published var fetchPhase = FetchPhase<[NodePoint]>.initial
    @Published var selectedX: Int?
    var chart: [NodePoint]? { fetchPhase.value }
    
    var selectedXRuleMark: (value: Int, text: String)? {
        if let index = (selectedX ?? nil),
           let chart = chart,
           index < chart.count
        {
            let selectedNode = chart[index]
            return (value: index, text: String(selectedNode.downloads))
        }
        return nil
    }
    
    
    private var _range: ChartRange {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: "selectedRange") {
                switch rawValue {
                case "oneWeek":
                    return .oneWeek
                case "oneMonth":
                    return .oneMonth
                case "threeMonth":
                    return .threeMonth
                case "sixMonth":
                    return .sixMonth
                case "oneYear":
                    return .oneYear
                case "twoYears":
                    return .twoYears
                case "fiveYears":
                    return .fiveYears
                case "tenYears":
                    return .tenYears
                default:
                    return .oneWeek
                }
            }
            return .oneWeek
        }
        set {
            UserDefaults.standard.set(newValue.title, forKey: "selectedRange")
        }
    }
    
    @Published var selectedRange = ChartRange.oneWeek {
        didSet {
            _range = selectedRange
        }
    }
    
    func fetchData(packageName: String) async {
        
        do {
            fetchPhase = .fetching
            let rangeType = self.selectedRange.dateRange
            let urlString = "https://api.npmjs.org/downloads/range/\(rangeType)/\(packageName)"
            guard let url = URL(string: urlString) else {
                print("Your API endpoint is invalid")
                return
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let response = try? JSONDecoder().decode(NodeEntry.self, from: data) {
                DispatchQueue.main.async {
                    self.fetchPhase = .success(response.downloads)
                }
            } else {
                fetchPhase = .empty
            }
        } catch {
            fetchPhase = .failure(error)
        }
    }
    
}
