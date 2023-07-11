//
//  ChartView.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 09.06.2023.
//

import SwiftUI
import SwiftUICharts
import Charts



struct ChartView: View {
    let data: [NodePoint]
    @ObservedObject var vm: ChartViewModel
    @State private var initColor: Color = .blue
    @State private var isDragged = false

    var body: some View {
        let downloads = data.map { ($0.day, Double($0.downloads)) }
        
        if !downloads.isEmpty {
            let totalDownloads = downloads.last?.1 ?? 0.0
            
                CardView(showShadow: false) {
                    VStack (alignment: .leading) {
                        ChartLabel(String(Int(totalDownloads)), type: .title, format: "%.f")
                        

                        LineChart()
                    }
                }
                .data(downloads)
                .frame(height: 200)
                .chartStyle(
                    ChartStyle(
                        backgroundColor: Color.clear,
                        foregroundColor: ColorGradient(initColor)
                    )
                )
                .onAppear{
                    initColor = calculateColor(downloads: downloads)
                }
                .onChange(of: isDragged) { newValue in
                    initColor = newValue ? .blue : calculateColor(downloads: downloads)
                }
                .gesture(
                    DragGesture()
                        .onChanged { _ in
                            print("2423")
                            isDragged = true
                        }
                        .onEnded { _ in
                            print("89798")
                            isDragged = false
                        }
                )
        }
    }
        
    private func calculateColor(downloads: [(String, Double)]) -> Color {
        guard downloads.count >= 2 else {
            return .blue
        }

        let lastTwoDownloads = Array(downloads.suffix(2)).map { $0.1 }

        if lastTwoDownloads[0] > lastTwoDownloads[1] {
            return .red
        } else {
            return .green
        }
    }
}

//struct ChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartView()
//    }
//}
