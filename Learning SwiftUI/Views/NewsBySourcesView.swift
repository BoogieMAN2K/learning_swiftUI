//
//  NewsBySources.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 15/02/2024.
//
import SwiftUI
import Combine

struct NewsBySourcesView: View {
    @MainActor @State private var newsSection = Set<String>()
    @State private var isDisplayingError: Bool = false
    @State private var networkRequest = NetworkRequest.instance
    @State private var cancellables = Set<AnyCancellable>()
    @State private var displayToolbar: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.recentNews) var recentNews

    var body: some View {
        NavigationStack {
            List {
                ForEach(newsSection.sorted(), id: \.self) { section in
                    Section(header: Text(section)) {
                        let newsForSection = recentNews.newsList.filter { $0.newsURL?.contains(section) ?? false }
                        ForEach(newsForSection) { newsArticle in
                            NavigationLink(destination: WebView(url: newsArticle.newsURL ?? "").navigationBarTitleDisplayMode(.inline)) {
                                NewsItemView(item: newsArticle)
                                    .ignoresSafeArea()
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Sorted by Sources")
        }
        .alert(isPresented: $isDisplayingError, content: {
            Alert(
                title: Text("Alert"),
                message: Text("Failed to load news."),
                dismissButton: .default(Text("OK"))
            )
        })
        .listStyle(.grouped)
        .onAppear {
            recentNews.newsList.forEach { article in
                newsSection.insert(article.source ?? "")
            }
        }
        .toolbar(displayToolbar ? .visible : .hidden)
    }
}

#Preview {
    NewsBySourcesView()
}
