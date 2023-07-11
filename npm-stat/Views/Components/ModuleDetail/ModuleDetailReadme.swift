//
//  ModuleDetailReadme.swift
//  npm-stat
//
//  Created by Sorin Gitlan on 23.06.2023.
//

import SwiftUI
import MarkdownUI

struct ModuleDetailReadme: View {
    @Binding var readme: String?
    @Binding var isLoadingMarkdown: Bool
    
    var body: some View {
        ScrollView {
            Spacer(minLength: 76)
            Group {
                if isLoadingMarkdown {
                    LoadingStateView()
                } else {
                    ScrollView {
                        Markdown(readme ?? "")
                    }
                }
            }
        }
    }
}

struct ModuleDetailReadme_Previews: PreviewProvider {
    static var previews: some View {
        let readme = "Hello, **SwiftLee** readers!"
        
        ModuleDetailReadme(readme: .constant(readme), isLoadingMarkdown: .constant(false))
    }
}
