//
//  ModuleRow.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 07.06.2023.
//

import SwiftUI

struct ModuleRow: View {
    var module: Package
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(module.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(module.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.trailing, 4)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Version: \(module.version)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(timeAgo(from: module.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    
    private func timeAgo(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: dateString) {
            let components = Calendar.current.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: date, to: Date())
            
            if let years = components.year, years > 0 {
                return "\(years) \(years == 1 ? "year" : "years") ago"
            } else if let months = components.month, months > 0 {
                return "\(months) \(months == 1 ? "month" : "months") ago"
            } else if let weeks = components.weekOfYear, weeks > 0 {
                return "\(weeks) \(weeks == 1 ? "week" : "weeks") ago"
            } else if let days = components.day, days > 0 {
                return "\(days) \(days == 1 ? "day" : "days") ago"
            } else if let hours = components.hour, hours > 0 {
                return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
            } else if let minutes = components.minute, minutes > 0 {
                return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
            }
        }
        return ""
    }
}

struct ModuleRow_Previews: PreviewProvider {
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
            return AnyView(ModuleRow(module: package)
                .previewLayout(.fixed(width: 300, height: 70)))
        } catch {
            print("Error decoding package:", error)
            return AnyView(Text("Error: \(error.localizedDescription)"))
        }

    }
}
