//
//  SearchItem.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 11.07.2023.
//

import SwiftUI

struct SearchItem: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.trailing, 4)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct SearchItem_Previews: PreviewProvider {
    static var previews: some View {
        SearchItem(title: "Vue", subtitle: "Lorem ipsum")
    }
}
