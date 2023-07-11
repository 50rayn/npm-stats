//
//  OverviewView.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 11.07.2023.
//

import SwiftUI

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

struct OverviewView: View {
    @Binding var moduleInfo: ModuleInfo?
    @ObservedObject var chartVM: ChartViewModel
    @Binding var period: String
    
    var body: some View {
        ScrollView {
            Spacer(minLength: 76)
            VStack(alignment: .leading, spacing: 20) {
                scrollView
                
                Text(moduleInfo?.description ?? "")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Version")
                        .font(.headline)
                    
                    Text(moduleInfo?.version ?? "")
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Package Details")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        if let keywords = moduleInfo?.keywords {
                            DetailRow(title: "Keywords", value: keywords.joined(separator: ", "))
                        }
                        DetailRow(title: "Maintainers", value: moduleInfo?.maintainers.map { $0.name }.joined(separator: ", ") ?? "")
                    }
                }
                
                Spacer()
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
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(
            moduleInfo: .constant(nil),
            chartVM: ChartViewModel(),
            period: .constant("last-week")
        )
    }
}
