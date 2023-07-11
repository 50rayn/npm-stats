//
//  SearchItem.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 11.07.2023.
//

import SwiftUI

struct SearchItem: View {
    var name: String
    var description: String
    var version: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.trailing, 4)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(version)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct SearchItem_Previews: PreviewProvider {
    static var previews: some View {
        SearchItem(name: "Vue", description: "Lorem ipsum", version: "1.0.0")
    }
}
