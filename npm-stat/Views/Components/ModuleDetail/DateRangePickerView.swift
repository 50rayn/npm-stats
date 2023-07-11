//
//  DateRangePickerView.swift
//  StocksApp
//
//  Created by Alfian Losari on 16/10/22.
//

import SwiftUI

enum ChartRange: Identifiable, CaseIterable {
    case oneWeek
    case oneMonth
    case threeMonth
    case sixMonth
    case oneYear
    case twoYears
    case fiveYears
    case tenYears
    
    var id: ChartRange {
        self
    }
    
    var title: String {
        switch self {
        case .oneWeek: return "1W"
        case .oneMonth: return "1M"
        case .threeMonth: return "3M"
        case .sixMonth: return "6M"
        case .oneYear: return "1Y"
        case .twoYears: return "2Y"
        case .fiveYears: return "5Y"
        case .tenYears: return "10Y"
        }
    }
    
    var dateRange: String {
        switch self {
        case .oneWeek:
            return ChartRange.custom(startDate: ChartRange.lastDays(7), endDate: ChartRange.currentDate)
        case .oneMonth:
            return ChartRange.custom(startDate: ChartRange.lastMonths(1), endDate: ChartRange.currentDate)
        case .threeMonth:
            return ChartRange.custom(startDate: ChartRange.lastMonths(3), endDate: ChartRange.currentDate)
        case .sixMonth:
            return ChartRange.custom(startDate: ChartRange.lastMonths(6), endDate: ChartRange.currentDate)
        case .oneYear:
            return ChartRange.custom(startDate: ChartRange.lastYears(1), endDate: ChartRange.currentDate)
        case .twoYears:
            return ChartRange.custom(startDate: ChartRange.lastYears(2), endDate: ChartRange.currentDate)
        case .fiveYears:
            return ChartRange.custom(startDate: ChartRange.lastYears(5), endDate: ChartRange.currentDate)
        case .tenYears:
            return ChartRange.custom(startDate: ChartRange.lastYears(10), endDate: ChartRange.currentDate)
        }
    }
    
    static var currentDate: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
    static func custom(startDate: Date, endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDateString = formatter.string(from: startDate)
        let endDateString = formatter.string(from: endDate)
        
        return "\(startDateString):\(endDateString)"
    }
    
    static func lastDays(_ count: Int) -> Date {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -count, to: currentDate)!
        return startDate
    }
    
    static func lastMonths(_ count: Int) -> Date {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .month, value: -count, to: currentDate)!
        return startDate
    }
    
    static func lastYears(_ count: Int) -> Date {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .year, value: -count, to: currentDate)!
        return startDate
    }
}

struct DateRangePickerView: View {
    let rangeTypes: [ChartRange] = ChartRange.allCases
    
    @Binding var selectedRange: ChartRange
    @Binding var selectedTitle: String

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                ForEach(rangeTypes, id: \.self) { dateRange in
                    Button(action: {
                        self.selectedRange = dateRange
                        self.selectedTitle = dateRange.title
                    }) {
                        Text(dateRange.title)
                            .font(.callout.bold())
                            .padding(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                    .background {
                        if dateRange == selectedRange {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.4))
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}


struct DateRangePickerView_Previews: PreviewProvider {
    
    @State static var dateRange = ChartRange.oneWeek
    @State static var dateTitle = ChartRange.oneWeek.title
    
    static var previews: some View {
        DateRangePickerView(selectedRange: $dateRange, selectedTitle: $dateTitle)
            .padding(.vertical)
            .previewLayout(.sizeThatFits)
    }
}
