//
//  NewsBySources.swift
//  Learning SwiftUI
//
//  Created by Victor Gil Alejandria on 15/02/2024.
//
import SwiftUI
import Combine

struct NewsBySourcesView: View {
    @MainActor @State private var news: [ArticleItem] = []
    @State private var isDisplayingError: Bool = false
    @State private var networkRequest = NetworkRequest.instance
    @State private var cancellables = Set<AnyCancellable>()
    @State private var displayToolbar: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.recentNews) var recentNews

    var body: some View {
        NavigationStack {
            List(news) { _ in
                ForEach(loadSections(articles: news).sorted(), id: \.self) { section in
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
            .onAppear {
                loadNews()
                if recentNews.ignoreCache {
                    recentNews.ignoreCache.toggle()
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
        .toolbar(displayToolbar ? .visible : .hidden)
    }

    @MainActor
    private func loadSections(articles: [ArticleItem]) -> Set<String> {
        var newsSections = Set<String>()
        articles.forEach { article in
            newsSections.insert(article.source ?? "")
        }

        return newsSections
    }

    @MainActor
    private func loadNews() {
        networkRequest.getNews(ignoreCache: recentNews.ignoreCache)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("Failed to load news: \(error.localizedDescription)")
                    isDisplayingError = true
                }
            } receiveValue: { newsResponse in
                // Some articles are coming with the title '[Removed]' so we need to filter those.
                news = newsResponse.articles.filter { $0.title != "[Removed]" }.map {
                    ArticleItem(title: $0.title ?? "",
                                date: formatStringToDate($0.publishedAt ?? ""),
                                summary: $0.description ?? "",
                                imageURL: $0.urlToImage ?? "",
                                newsURL: $0.url,
                                source: networkRequest.getDomain(from: $0.url ?? ""))
                }

                self.recentNews.newsList = news
            }
            .store(in: &cancellables)
    }

}

#Preview {
    NewsBySourcesView()
}
